## Context

Metrics (Prometheus) and logs (Loki) are both fully wired through the observability stack; traces are the last signal from the Phase 1 epic (#14) still unwired. The collector's `traces` pipeline exists but only logs to `debug`, and `hello`'s `otelhttp` middleware is already in place around the `/` handler but silently no-ops because no `TracerProvider` is registered. All backend/vendor decisions for this change were made in a grilling session prior to this proposal and recorded in ADR-0012; this document captures the resulting implementation shape.

## Goals / Non-Goals

**Goals:**
- Deploy Tempo and get a real trace from a `hello` request visible in Grafana (#67's stated done-when)
- Follow the exact deploy pattern already established by Loki (monolithic chart, filesystem+PVC storage, sidecar-discovered Grafana datasource)

**Non-Goals:**
- Trace-to-logs/metrics correlation (exemplars, `tracesToLogs`/`tracesToMetrics`) — tracked separately as #87
- Any sampling strategy — tracked separately as #88; the SDK default (`ParentBased(AlwaysSample)`) applies
- Multi-service traces / distributed context propagation across services — only `hello` exists today

## Decisions

**Tempo over Jaeger, monolithic chart** — see ADR-0012. Not re-litigated here.

**PVC size: 1Gi, not Loki's 5Gi** — trace data is smaller per-request than log lines (no message bodies), and only one service is instrumented. Reversible via a Helm values change if usage outgrows it; not worth over-provisioning up front.

**Collector→Tempo hop: `otlphttp`, not `otlp` (grpc)** — avoids adding a grpc client dependency to the collector's exporter config for this hop; consistent with keeping the collector's own footprint minimal. This is independent of the `hello`→collector hop, which already uses http for unrelated reasons (browser/curl-friendliness at that edge).

**Debug exporter dropped from the `traces` pipeline** — mirrors exactly what happened to the `metrics` pipeline when Prometheus was wired (`otel-collector.yaml`'s `metrics: exporters: [prometheusremotewrite]`, no `debug`). The `logs` pipeline keeps `debug` only because it's a permanently unused stub (ADR-0011: Alloy bypasses the collector for logs entirely).

**`hello`: sibling `SetupTraces` function, not a unified `Setup`** — keeps metrics and traces fully decoupled in both code and tests, mirroring how the collector's `metrics`/`traces`/`logs` pipelines are already configured independently of each other. `main.go` gets a second `shutdown` func to defer alongside the existing one. The only shared plumbing between the two is the existing `newResource` helper.

**Grafana datasource: minimal, no correlation** — mirrors the existing Loki datasource ConfigMap shape exactly (`type`, `access: proxy`, `url`, `isDefault: false`, `editable: false`). Correlation fields are deliberately absent per #87.

## Risks / Trade-offs

- **[Risk]** 1Gi PVC may be undersized if trace volume is higher than expected → **Mitigation**: `kubectl get pvc -n observability` after deploy to check fill rate; resizing is a one-line Helm values change plus PVC resize (StorageClass permitting), not a re-architecture.
- **[Risk]** No sampling means every request is traced; if `hello`'s traffic or instrumented-service count grows before #88 lands, this could add unnecessary load to the collector and Tempo → **Mitigation**: explicitly tracked as #88; current traffic is trivial so this is accepted for now.
- **[Risk]** `otlphttp` exporter choice for the collector→Tempo hop is a minor, low-consequence guess (no established precedent either way in this codebase) → **Mitigation**: trivially reversible (a chart values + exporter type change), not worth deeper investigation up front.

## Migration Plan

No existing data or running signal path to migrate — this is a net-new pipeline. Deploy order follows ArgoCD sync-wave dependencies already in place: `tempo` (wave matching Loki, `"1"`) before `grafana-datasource`'s Tempo entry (wave `"2"`, matching the existing Prometheus/Loki datasource entries) before the collector's `traces` pipeline change takes effect meaningfully (the pipeline change itself has no ordering dependency — it can sync any time, but traces will only successfully land once Tempo is up). Rollback is reverting the relevant manifests; nothing here is stateful in a way that complicates rollback (a 72h-retention PVC is disposable).

## Open Questions

None outstanding — all decisions were resolved in the preceding grilling session (see ADR-0012 for the backend choice; this document for the rest).
