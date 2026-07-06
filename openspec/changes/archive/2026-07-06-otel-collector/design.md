## Context

This is the first piece of the Phase 1 observability epic (#14) to land. Nothing in the cluster currently emits or consumes telemetry — `hello` has no OTel SDK wired in yet (#61), and no metrics/logs/traces backend exists (#62/#66/#67). The collector is deployed alone, ahead of any consumer, so its only job here is to prove the ingestion pipe works: accept OTLP, log what it received, and stop. `docs/adr/0008-observability-namespace.md` already fixes the namespace (`observability`, shared across the whole future stack) and `docs/adr/0009-otel-collector-contrib-over-alloy.md` already fixes the vendor and mode (Collector Contrib, `mode: deployment`). This design covers the remaining "how": chart source, values shape, resource sizing, and verification sequencing.

## Goals / Non-Goals

**Goals:**
- Get a healthy Collector Contrib Deployment running in the `observability` namespace, synced by ArgoCD like every other workload.
- Accept OTLP over both grpc (`4317`) and http (`4318`).
- Prove receipt by logging payloads to the `debug` exporter only.
- Keep the pod's resource footprint explicit and small, against the epic's ~7.4Gi RAM headroom.

**Non-Goals:**
- Wiring any real backend (metrics, logs, traces) — that's #62/#66/#67.
- Fixing a stable Service/DNS name for consumers — left to #61, which is the first actual consumer.
- Node-local scraping (`hostmetrics`, `filelog`) — no receiver for that is in scope; would imply `mode: daemonset` per ADR-0009, revisited at #66.

## Decisions

- **Helm chart sourced directly in the ArgoCD Application**, mirroring `deploy/apps/cert-manager.yaml`'s pattern (`source.chart` + `source.repoURL` pointing at the chart repo, `helm.values` inline) rather than vendoring rendered manifests the way `sealed-secrets` does. Chart: `open-telemetry/opentelemetry-collector` from `https://open-telemetry.github.io/opentelemetry-helm-charts`. Alternative considered: vendor manifests under `deploy/observability/otel-collector/` — rejected, since there's no reason to diverge from the precedent cert-manager already set for well-maintained upstream charts, and it avoids hand-tracking CRD/RBAC updates.
- **`image.repository` set to the Contrib image** (`otel/opentelemetry-collector-contrib`), since the chart defaults to the core distribution, which lacks the receiver/exporter surface Contrib provides for later phases (#66/#67 will need components core doesn't ship).
- **Pipelines wire `otlp` straight to `debug`** for all three signal types (traces/metrics/logs) the receiver can carry, even though only debug output is used today — this matches "prove the pipe," not just one signal type, and costs nothing extra.
- **`sync-wave: "0"`**, matching every other Application with no dependencies (cert-manager, sealed-secrets) — nothing here depends on any other Application, and nothing yet depends on it.
- **Resources**: modest requests/limits (indicative: `requests: 100m/128Mi`, `limits: 500m/256Mi` — tune once real values are visible from the running pod) rather than chart defaults, so the epic's RAM tracking has a real number for this component from day one instead of an unbounded pod.

## Risks / Trade-offs

- **[Risk]** Contrib's larger image/RBAC surface than core, for a component only using one receiver and one exporter today → **[Mitigation]** Accepted: #66/#67 already commit to Contrib-only components (Loki/traces exporters aren't in core), so switching to core now and back to Contrib later would just be churn.
- **[Risk]** No CI equivalent of a running k3s cluster means the collector's actual health can only be confirmed after ArgoCD syncs to the Beelink → **[Mitigation]** Sequence tasks so any push-a-test-payload verification is the last task, after sync, per the proposal's Impact note (same pattern `traefik-https-redirect` used for its post-deploy `curl` checks).
- **[Risk]** Resource limits picked before real traffic exists may be wrong in either direction → **[Mitigation]** Low stakes: adjusting Helm values later is a one-line, low-risk change, not an architectural one.

## Migration Plan

1. Add `deploy/apps/otel-collector.yaml` (new Application, Helm-sourced, `observability` namespace, `CreateNamespace=true`).
2. Commit and let ArgoCD sync — no manual `kubectl apply`, per `deploy/CLAUDE.md`.
3. Verify pod health and namespace placement.
4. Push a test OTLP payload and confirm it appears in the collector's debug-exporter logs (last task — requires the live sync from step 2).

No rollback complexity: deleting the Application (or letting `prune: true` remove it) tears down the whole thing cleanly, since nothing else depends on it yet.

## Open Questions

- Exact resource request/limit values are indicative pending real observation post-deploy — tighten once the pod's actual footprint is visible (tracked as a task, not blocking initial deploy).
