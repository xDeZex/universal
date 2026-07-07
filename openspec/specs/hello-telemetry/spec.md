# hello-telemetry Specification

## Purpose
TBD - created by archiving change instrument-hello-otel-metrics. Update Purpose after archive.
## Requirements
### Requirement: Root endpoint requests are recorded as OTel HTTP metrics

The `/` handler SHALL be wrapped with `otelhttp` instrumentation under operation name `"root"`, recording request count and duration for every request regardless of outcome.

#### Scenario: Happy path — successful request recorded

- **WHEN** a client sends `GET /`
- **THEN** the response is unchanged (200, JSON identity body) and a metric data point is recorded tagged with operation `"root"`

#### Scenario: Error/rejection — rejected request still recorded

- **WHEN** a client sends `POST /` (rejected with 405 per the existing `hello-service` requirement)
- **THEN** the response is still 405 and a metric data point is recorded reflecting the 405 status, unaffected by instrumentation

#### Scenario: Contract — resource attributes attached to every export

- **WHEN** metrics recorded on `/` are exported
- **THEN** they carry `service.name` and `service.version` resource attributes identifying the emitting process

### Requirement: Health endpoint is excluded from telemetry

`/healthz` SHALL NOT be wrapped with `otelhttp` or otherwise emit metrics, since it cannot report anything but success today and would only add k8s-probe-driven noise.

#### Scenario: Happy path — probe traffic generates no telemetry

- **WHEN** a client sends `GET /healthz`
- **THEN** the response is unchanged (200, empty body) and no metric data point is recorded for this request

#### Scenario: Error/rejection — rejected healthz request still generates no telemetry

- **WHEN** a client sends `POST /healthz` (rejected with 405 per the existing `hello-service` requirement)
- **THEN** the response is still 405 and no metric data point is recorded

### Requirement: Metrics are pushed via OTLP over HTTP to the otel-collector

The service SHALL export metrics using `otlpmetrichttp` on a `PeriodicReader`, targeting the collector's http endpoint. The endpoint SHALL be supplied via a `ConfigMap` (`OTEL_EXPORTER_OTLP_ENDPOINT`) wired into the Deployment through `envFrom`, using the generic (non-signal-specific) endpoint variable.

#### Scenario: Happy path — metrics reach the collector

- **WHEN** the `PeriodicReader` triggers an export
- **THEN** the SDK POSTs OTLP-encoded metrics to `http://otel-collector-opentelemetry-collector.observability.svc.cluster.local:4318/v1/metrics`, and the collector forwards it per its own pipeline configuration (see `otel-collector` capability), rather than a hardcoded downstream exporter

#### Scenario: Error/rejection — collector unreachable

- **WHEN** the collector is unreachable at export time
- **THEN** the export failure is logged via the SDK's internal error handler and does not crash `hello` or affect its HTTP responses

#### Scenario: Contract — endpoint sourced from ConfigMap, not hardcoded

- **WHEN** `deploy/services/hello/deployment.yaml` is inspected
- **THEN** `OTEL_EXPORTER_OTLP_ENDPOINT` SHALL be populated via `envFrom` from a `ConfigMap` local to `deploy/services/hello/`, not a literal value in the Deployment spec or Go code

### Requirement: Service identifies itself via service.name and service.version

The MeterProvider's resource SHALL set `service.name` from the `OTEL_SERVICE_NAME` env var (delivered via the same ConfigMap) and `service.version` from the existing build-time `version` Go variable (the git SHA baked in via `-ldflags`), not a second env var.

#### Scenario: Happy path — resource attributes match running build

- **WHEN** the MeterProvider is initialized
- **THEN** its resource has `service.name` = `"hello"` and `service.version` equal to the same value returned by `GET /`'s `version` field

#### Scenario: Error/rejection — no build-time version override

- **WHEN** the service runs without `-ldflags` overriding `version` (e.g. a local/dev build)
- **THEN** `service.version` is `"dev"` rather than empty or missing

### Requirement: Root endpoint requests produce OTel trace spans

The `otelhttp` instrumentation already wrapping the `/` handler (under operation name `"root"`) SHALL produce real spans once a `TracerProvider` is registered, rather than the no-op tracer it silently falls back to today.

#### Scenario: Happy path — successful request produces a span

- **WHEN** a client sends `GET /`
- **THEN** the response is unchanged (200, JSON identity body) and a span is recorded tagged with operation `"root"`

#### Scenario: Error/rejection — rejected request still produces a span

- **WHEN** a client sends `POST /` (rejected with 405 per the existing `hello-service` requirement)
- **THEN** the response is still 405 and a span is still recorded, reflecting the 405 status, unaffected by instrumentation

#### Scenario: Contract — resource attributes attached to every span

- **WHEN** spans recorded on `/` are exported
- **THEN** they carry `service.name` and `service.version` resource attributes identifying the emitting process

### Requirement: Traces are pushed via OTLP over HTTP to the otel-collector

The service SHALL export traces using `otlptracehttp` on a `BatchSpanProcessor`, targeting the collector's http endpoint via the same generic `OTEL_EXPORTER_OTLP_ENDPOINT` ConfigMap value the metrics exporter already uses — no separate signal-specific endpoint variable.

#### Scenario: Happy path — traces reach the collector

- **WHEN** the `BatchSpanProcessor` flushes
- **THEN** the SDK POSTs OTLP-encoded spans to `http://otel-collector-opentelemetry-collector.observability.svc.cluster.local:4318/v1/traces`, and the collector forwards it per its own pipeline configuration (see `otel-collector` capability), rather than a hardcoded downstream exporter

#### Scenario: Error/rejection — collector unreachable

- **WHEN** the collector is unreachable at export time
- **THEN** the export failure is logged via the SDK's internal error handler and does not crash `hello` or affect its HTTP responses

#### Scenario: Contract — endpoint sourced from the existing ConfigMap, not hardcoded

- **WHEN** `deploy/services/hello/otel-config.yaml` and the trace exporter's configuration are compared
- **THEN** the trace exporter SHALL read `OTEL_EXPORTER_OTLP_ENDPOINT` from the same ConfigMap the metrics exporter uses, not a new or literal value

### Requirement: Trace resource identifies service via service.name and service.version

The `TracerProvider`'s resource SHALL set `service.name` and `service.version` using the same `newResource` construction the `MeterProvider` already uses, so both signals report identical resource attributes for the same running process.

#### Scenario: Happy path — resource attributes match running build

- **WHEN** the `TracerProvider` is initialized
- **THEN** its resource has `service.name` = `"hello"` and `service.version` equal to the same value returned by `GET /`'s `version` field

#### Scenario: Error/rejection — no divergence from the metrics resource

- **WHEN** the `TracerProvider`'s resource and the `MeterProvider`'s resource are compared
- **THEN** their `service.name` and `service.version` attributes SHALL be identical

