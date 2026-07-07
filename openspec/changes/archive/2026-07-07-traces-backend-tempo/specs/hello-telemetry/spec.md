## ADDED Requirements

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
