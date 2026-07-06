## Why

Phase 1 (observability, #14) needs a telemetry ingestion point before anything can be instrumented against it. #63 is the first task on that epic: stand up an OpenTelemetry Collector that accepts OTLP and proves the pipe works, with no backend wired yet — #61 (instrumenting `hello`) and #62 (metrics backend) both depend on this existing first.

## What Changes

- Deploy OpenTelemetry Collector **Contrib** via its upstream Helm chart, in `mode: deployment` (ADR-0009).
- New ArgoCD Application `deploy/apps/otel-collector.yaml`, Helm-sourced (same pattern as `cert-manager`), targeting the shared `observability` namespace (ADR-0008).
- Chart values configure the `otlp` receiver (grpc `:4317` + http `:4318`) and a `debug` exporter only — no metrics/logs/traces backend.
- Explicit resource requests/limits on the collector pod, tracked against the epic's stated ~7.4Gi RAM headroom.
- No Service/DNS name is fixed for consumers yet — left for #61 to pin down when a real consumer exists.

## Capabilities

### New Capabilities
- `otel-collector`: An Observability component (deploy/observability/otel-collector/, per the new CONTEXT.md term) that runs the OpenTelemetry Collector Contrib in-cluster, receiving OTLP over grpc/http and exporting to `debug` only.

### Modified Capabilities

(none — this introduces a new, currently unconsumed component; no existing spec's requirements change)

## Impact

- **Affected**: `deploy/apps/otel-collector.yaml` (new), `deploy/observability/otel-collector/` (new, if any non-Helm-values manifests are needed)
- **New namespace**: `observability`, created via `CreateNamespace=true` sync option, shared with future Observability components (Grafana, Loki, a traces backend — ADR-0008)
- **Verification is a post-deploy step, not a CI step**: "the collector runs and logs received OTLP payloads to its own debug output" can only be confirmed after ArgoCD syncs this to the live Beelink cluster — there is no local/CI equivalent of a running k3s cluster. Any push-a-test-payload verification task must come last in `tasks.md`, after the sync itself, the same way `traefik-https-redirect` sequenced its `curl` verification after deploy.
- **No impact** to existing Services or Infra components — this is additive only.
