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

### Requirement: Debug exporter only, no backend wired

Every configured pipeline (traces, metrics, logs) SHALL export exclusively to the `debug` exporter. No pipeline SHALL send data to any metrics, logs, or traces backend.

#### Scenario: Happy path — received payload logged to debug output

- **WHEN** an OTLP payload is received on either receiver endpoint
- **THEN** its contents appear in the collector pod's own container logs via the `debug` exporter

#### Scenario: Error/rejection — no backend exporter configured

- **WHEN** the collector's exporter and pipeline configuration is reviewed
- **THEN** it SHALL NOT reference any exporter other than `debug` (no `prometheusremotewrite`, `otlphttp` to an external backend, `loki`, etc.)

### Requirement: Collector resource requests/limits are set against the phase RAM budget

The collector Deployment SHALL specify explicit CPU/memory requests and limits, sized to fit within the Phase 1 epic's (#14) documented ~7.4Gi remaining headroom rather than left at chart defaults.

#### Scenario: Happy path — pod scheduled within defined bounds

- **WHEN** the collector pod is scheduled
- **THEN** it has non-empty `resources.requests` and `resources.limits` for both CPU and memory

#### Scenario: Error/rejection — no unbounded deployment

- **WHEN** the Helm values are reviewed
- **THEN** they SHALL NOT omit `resources`, leaving the pod unbounded against the shared node's budget
