# tempo Specification

## Purpose
TBD - created by archiving change traces-backend-tempo. Update Purpose after archive.
## Requirements
### Requirement: Tempo runs as an Observability component in monolithic mode

Tempo SHALL be installed via a dedicated ArgoCD Application (`deploy/apps/tempo.yaml`) sourcing the upstream `grafana/tempo` Helm chart directly (the monolithic single-binary chart, not `grafana/tempo-distributed`), running in the shared `observability` namespace (ADR-0008).

#### Scenario: Happy path — Application synced and Tempo healthy

- **WHEN** the `tempo` Application is synced by ArgoCD
- **THEN** the Tempo pod runs in the `observability` namespace and reports healthy

#### Scenario: Error/rejection — no distributed chart

- **WHEN** the Application's Helm values are reviewed
- **THEN** the chart SHALL be `grafana/tempo` (monolithic), not `grafana/tempo-distributed`

#### Scenario: Contract — Helm chart sourced directly

- **WHEN** the ArgoCD Application spec is inspected
- **THEN** its `source` SHALL reference the upstream `grafana/tempo` Helm chart repo (not a git path of vendored manifests)

### Requirement: Tempo stores traces on filesystem, not an object store

Tempo SHALL be configured with `local` filesystem storage for trace blocks, backed by a PVC using the `observability-retain` StorageClass, sized `1Gi` — no S3, GCS, or minio dependency.

#### Scenario: Happy path — traces survive a pod restart

- **WHEN** the Tempo pod restarts
- **THEN** previously ingested trace blocks remain queryable, read from the PVC

#### Scenario: Error/rejection — no object storage backend configured

- **WHEN** the Helm values are reviewed
- **THEN** they SHALL NOT configure an `s3`, `gcs`, or `azure` storage backend, or a bundled minio deployment

#### Scenario: Contract — PVC references the observability-retain StorageClass

- **WHEN** Tempo's persistent volume configuration is inspected
- **THEN** its `storageClassName` SHALL be `observability-retain`, sized `1Gi`

### Requirement: Trace retention is bounded to 72 hours

Tempo's compactor SHALL be configured with `block_retention: 72h`, matching Loki's log retention window rather than the chart's longer default.

#### Scenario: Happy path — data within retention is queryable

- **WHEN** a trace ingested less than 72 hours ago is queried
- **THEN** Tempo returns it

#### Scenario: Error/rejection — no unbounded or default retention

- **WHEN** the Helm values are reviewed
- **THEN** `compactor.compaction.block_retention` SHALL be explicitly set to `72h`, not left at the chart default

### Requirement: Resource requests/limits are set against the phase RAM budget

The Tempo pod SHALL specify explicit CPU/memory requests and limits, sized to fit within the Phase 1 epic's (#14) documented RAM headroom rather than left at chart defaults.

#### Scenario: Happy path — pod scheduled within defined bounds

- **WHEN** the Tempo pod is scheduled
- **THEN** it has non-empty `resources.requests` and `resources.limits` for both CPU and memory

#### Scenario: Error/rejection — no unbounded deployment

- **WHEN** the Helm values are reviewed
- **THEN** they SHALL NOT omit `resources`, leaving the pod unbounded against the shared node's budget

### Requirement: Tempo accepts traces on its native OTLP receiver

Tempo SHALL expose its built-in OTLP receiver (grpc `4317` and http `4318`) on its in-cluster Service, as the target for the otel-collector's `traces` pipeline export — no separate gateway/proxy component in front of it.

#### Scenario: Happy path — collector's exported traces are ingested

- **WHEN** the otel-collector's `traces` pipeline exports a batch via `otlphttp`
- **THEN** Tempo ingests it on its OTLP http endpoint and the trace becomes queryable

#### Scenario: Contract — Service DNS name matches the collector's configured exporter endpoint

- **WHEN** Tempo's in-cluster Service DNS name and the `otel-collector` Application's `otlphttp` exporter endpoint are compared
- **THEN** both SHALL resolve to the same Service
