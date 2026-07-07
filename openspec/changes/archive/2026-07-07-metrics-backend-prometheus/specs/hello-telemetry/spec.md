## MODIFIED Requirements

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
