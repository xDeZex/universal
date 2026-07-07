# otel-collector Specification

## Purpose
TBD - created by archiving change otel-collector. Update Purpose after archive.
## Requirements
### Requirement: OTel Collector Contrib runs as an Observability component

The OpenTelemetry Collector **Contrib** distribution SHALL be installed via a dedicated ArgoCD Application (`deploy/apps/otel-collector.yaml`) sourcing the upstream `opentelemetry-collector` Helm chart directly (not vendored manifests), in `mode: deployment`, running in the shared `observability` namespace (ADR-0008) rather than a namespace of its own.

#### Scenario: Happy path — Application synced and collector healthy

- **WHEN** the `otel-collector` Application is synced by ArgoCD
- **THEN** the collector pod runs in the `observability` namespace as a Deployment and reports healthy

#### Scenario: Error/rejection — no dedicated namespace

- **WHEN** the Application's manifests are reviewed
- **THEN** they SHALL NOT create or target any namespace other than `observability`, keeping it out of the per-component isolation pattern ADR-0005 uses for Infra components

#### Scenario: Contract — Helm chart sourced directly, values forwarded correctly

- **WHEN** the ArgoCD Application spec is inspected
- **THEN** its `source` SHALL reference the upstream `opentelemetry-collector` Helm chart repo (not a git path of vendored manifests), and `helm.values` SHALL set `mode: deployment`

### Requirement: OTLP receiver accepts both grpc and http

The collector's `otlp` receiver SHALL be enabled on both its grpc (`4317`) and http (`4318`) endpoints, as the only receiver configured.

#### Scenario: Happy path — grpc OTLP payload accepted

- **WHEN** an OTLP payload is sent to the collector's grpc endpoint on port `4317`
- **THEN** the collector accepts it without error

#### Scenario: Happy path — http OTLP payload accepted

- **WHEN** an OTLP payload is sent to the collector's http endpoint on port `4318`
- **THEN** the collector accepts it without error

#### Scenario: Error/rejection — no other receiver enabled

- **WHEN** the collector's receiver configuration is reviewed
- **THEN** it SHALL NOT enable any receiver other than `otlp` (e.g. no `prometheus` scrape receiver, no `filelog`), since nothing besides direct OTLP push is in scope for this issue

### Requirement: Metrics pipeline exports to Prometheus

The collector's metrics pipeline SHALL export exclusively to a `prometheusremotewrite` exporter pointed at the Prometheus Observability component's remote-write endpoint. No other exporter SHALL be referenced by the metrics pipeline.

#### Scenario: Happy path — metrics payload forwarded to Prometheus

- **WHEN** an OTLP metrics payload is received on either receiver endpoint
- **THEN** its data points are forwarded to Prometheus via the `prometheusremotewrite` exporter and become queryable there within one export interval

#### Scenario: Error/rejection — no other metrics exporter configured

- **WHEN** the metrics pipeline's exporter configuration is reviewed
- **THEN** it SHALL NOT reference `debug` or any exporter other than `prometheusremotewrite`

#### Scenario: Contract — remote-write endpoint matches Prometheus's Service

- **WHEN** the `prometheusremotewrite` exporter's configuration is inspected
- **THEN** its endpoint SHALL match the Prometheus Observability component's in-cluster Service DNS name and remote-write path

### Requirement: Logs pipeline remains debug-only, an intentionally unused stub

The collector's `logs` pipeline SHALL continue to export exclusively to the `debug` exporter. This is permanent, not pending a future backend: ADR-0011 routes log collection through Alloy directly to Loki, bypassing the collector entirely, so this pipeline stays an unused stub by design.

#### Scenario: Happy path — logs payload logged to debug output

- **WHEN** an OTLP logs payload is received on either receiver endpoint
- **THEN** its contents appear in the collector pod's own container logs via the `debug` exporter

#### Scenario: Error/rejection — no backend exporter configured for logs

- **WHEN** the logs pipeline's exporter configuration is reviewed
- **THEN** it SHALL NOT reference any exporter other than `debug`

### Requirement: Traces pipeline exports to Tempo

The collector's `traces` pipeline SHALL export exclusively to an `otlphttp` exporter pointed at the Tempo Observability component's OTLP http endpoint. No other exporter SHALL be referenced by the traces pipeline.

#### Scenario: Happy path — traces payload forwarded to Tempo

- **WHEN** an OTLP traces payload is received on either receiver endpoint
- **THEN** it is forwarded to Tempo via the `otlphttp` exporter and becomes queryable there

#### Scenario: Error/rejection — no other traces exporter configured

- **WHEN** the traces pipeline's exporter configuration is reviewed
- **THEN** it SHALL NOT reference `debug` or any exporter other than `otlphttp`

#### Scenario: Contract — endpoint matches Tempo's Service

- **WHEN** the `otlphttp` exporter's traces endpoint is inspected
- **THEN** it SHALL match the Tempo Observability component's in-cluster Service DNS name and OTLP http port

### Requirement: Collector resource requests/limits are set against the phase RAM budget

The collector Deployment SHALL specify explicit CPU/memory requests and limits, sized to fit within the Phase 1 epic's (#14) documented ~7.4Gi remaining headroom rather than left at chart defaults.

#### Scenario: Happy path — pod scheduled within defined bounds

- **WHEN** the collector pod is scheduled
- **THEN** it has non-empty `resources.requests` and `resources.limits` for both CPU and memory

#### Scenario: Error/rejection — no unbounded deployment

- **WHEN** the Helm values are reviewed
- **THEN** they SHALL NOT omit `resources`, leaving the pod unbounded against the shared node's budget
