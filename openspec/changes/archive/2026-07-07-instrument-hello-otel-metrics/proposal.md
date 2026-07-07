## Why

`hello` has no telemetry today — the otel-collector (#63) runs but receives nothing to prove the pipe works end to end. Issue #61 (part of the Phase 1 observability epic, #14) instruments `hello` with the OTel Go SDK and pushes metrics to the collector, so the collector's debug exporter shows real payloads before further observability work (dashboards, alerts) builds on top of it.

## What Changes

- Add a `services/hello/internal/telemetry` subpackage that sets up a `MeterProvider` with an OTLP HTTP metric exporter (`otlpmetrichttp`) and a `PeriodicReader`, plus a resource carrying `service.name` (env var) and `service.version` (the existing build-time `version` var)
- Wrap the `/` handler only with `go.opentelemetry.io/contrib/instrumentation/net/http/otelhttp` (operation name `"root"`), emitting RED-style request count/duration metrics; `/healthz` stays uninstrumented since it cannot report anything but success today
- Add a `ConfigMap` in `deploy/services/hello/` supplying `OTEL_EXPORTER_OTLP_ENDPOINT` (pointing at the collector's http endpoint, `otel-collector-opentelemetry-collector.observability.svc.cluster.local:4318`) and `OTEL_SERVICE_NAME`, wired into the Deployment via `envFrom`
- Add tests using an in-memory `metric.NewManualReader()` (no real OTLP exporter) to assert the `otelhttp`-wrapped handler records metrics, alongside the existing `httptest`-based handler tests

## Capabilities

### New Capabilities
- `hello-telemetry`: OTel SDK metrics instrumentation for the `hello` service — the MeterProvider/exporter setup, which routes are instrumented, resource attributes, and the ConfigMap-based OTLP endpoint configuration.

### Modified Capabilities

(none — `hello-service` and `hello-deployment`'s existing requirements are unchanged; this only adds a new capability alongside them)

## Impact

- `services/hello/main.go`: wraps `/` with `otelhttp`, calls `telemetry.Setup`/shutdown
- `services/hello/internal/telemetry/` (new): MeterProvider bootstrap
- `services/hello/go.mod`: new deps (`go.opentelemetry.io/otel`, `.../sdk/metric`, `.../exporters/otlp/otlpmetric/otlpmetrichttp`, `.../contrib/instrumentation/net/http/otelhttp`)
- `deploy/services/hello/`: new ConfigMap manifest, `deployment.yaml` gains `envFrom`
- No changes to `otel-collector` or its spec — it already accepts OTLP on both grpc/http with a debug-only pipeline
