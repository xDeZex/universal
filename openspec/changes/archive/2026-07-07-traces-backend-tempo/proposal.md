## Why

The Phase 1 observability epic (#14) has metrics (Prometheus) and logs (Loki) wired end to end, but traces have no backend — the collector's `traces` pipeline still only logs to `debug`, and `hello` has no `TracerProvider` registered, so its `otelhttp` middleware silently no-ops. #67 closes that gap: pick and deploy a traces backend, wire the collector's traces pipeline to it, and instrument `hello` so a real trace becomes visible.

## What Changes

- Deploy Tempo (monolithic `grafana/tempo` chart) as a new Observability component, PVC-backed (`observability-retain`, `1Gi`), `block_retention: 72h` (ADR-0012)
- Wire the collector's `traces` pipeline to export to Tempo via `otlphttp`, dropping the `debug` exporter
- Add a Tempo datasource to Grafana, following the same sidecar-discovered ConfigMap pattern as the existing Prometheus/Loki datasources — no trace-to-logs/metrics correlation config (deferred to #87)
- Add tracer SDK setup to `hello`: a `telemetry.SetupTraces` function (sibling to the existing `telemetry.Setup` for metrics), registering a real `TracerProvider` so the already-present `otelhttp` middleware starts producing spans
- No sampling configuration — the OTel SDK default (`ParentBased(AlwaysSample)`) applies; a deliberate strategy is deferred to #88

## Capabilities

### New Capabilities
- `tempo`: Tempo Observability component — deploy shape, storage/retention, resource limits

### Modified Capabilities
- `otel-collector`: traces pipeline moves from debug-only to exporting to Tempo via `otlphttp`
- `hello-telemetry`: adds tracer SDK setup and registration alongside the existing metrics setup
- `grafana-datasource`: adds a Tempo datasource alongside the existing Prometheus/Loki ones

## Impact

- `deploy/apps/tempo.yaml` (new)
- `deploy/apps/otel-collector.yaml` (traces pipeline exporter change)
- `deploy/observability-config/grafana-datasource/` (new Tempo ConfigMap + kustomization update)
- `services/hello/internal/telemetry/` (new `SetupTraces`, new tests)
- `services/hello/main.go` (call `SetupTraces`, defer its shutdown)
- Reuses the existing `observability-retain` StorageClass (`observability-storage` capability) — no change to that capability
- Closes #67; #87 (correlation) and #88 (sampling) remain open as separate follow-ups
