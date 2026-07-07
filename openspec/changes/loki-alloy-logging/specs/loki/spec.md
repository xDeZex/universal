## ADDED Requirements

### Requirement: Loki runs as an Observability component in SingleBinary mode

Loki SHALL be installed via a dedicated ArgoCD Application (`deploy/apps/loki.yaml`) sourcing the upstream `grafana/loki` Helm chart directly, deployed in `SingleBinary` mode (one process handling ingestion, storage, and query), running in the shared `observability` namespace (ADR-0008).

#### Scenario: Happy path — Application synced and Loki healthy

- **WHEN** the `loki` Application is synced by ArgoCD
- **THEN** the Loki pod runs in the `observability` namespace and reports healthy

#### Scenario: Error/rejection — no distributed/scalable mode

- **WHEN** the Application's Helm values are reviewed
- **THEN** `deploymentMode` (or chart equivalent) SHALL be `SingleBinary`, not `SimpleScalable` or a distributed microservices mode

#### Scenario: Contract — Helm chart sourced directly

- **WHEN** the ArgoCD Application spec is inspected
- **THEN** its `source` SHALL reference the upstream `grafana/loki` Helm chart repo (not a git path of vendored manifests)

### Requirement: Loki stores chunks and indexes on filesystem, not an object store

Loki SHALL be configured with `filesystem` storage for both chunks and the index, backed by a PVC using the `observability-retain` StorageClass — no S3, GCS, or minio dependency.

#### Scenario: Happy path — logs survive a pod restart

- **WHEN** the Loki pod restarts
- **THEN** previously ingested log chunks remain queryable, read from the PVC

#### Scenario: Error/rejection — no object storage backend configured

- **WHEN** the Helm values are reviewed
- **THEN** they SHALL NOT configure an `s3`, `gcs`, or `azure` storage backend, or a bundled minio deployment

#### Scenario: Contract — PVC references the observability-retain StorageClass

- **WHEN** Loki's persistent volume configuration is inspected
- **THEN** its `storageClassName` SHALL be `observability-retain`, matching Prometheus's PVC, sized `5Gi`

### Requirement: Log retention is bounded to 3 days

Loki SHALL be configured with a retention period of exactly 3 days, shorter than Prometheus's 7-day metric retention, reflecting logs' higher volume per unit time relative to metric samples.

#### Scenario: Happy path — data within retention is queryable

- **WHEN** a log line ingested less than 3 days ago is queried
- **THEN** Loki returns it

#### Scenario: Error/rejection — no unbounded retention

- **WHEN** the Helm values are reviewed
- **THEN** they SHALL NOT leave retention at an unbounded or default-forever setting; the compactor's retention period SHALL be set to `72h` (or chart equivalent)

### Requirement: Resource requests/limits are set against the phase RAM budget

The Loki pod SHALL specify explicit CPU/memory requests and limits, sized to fit within the Phase 1 epic's (#14) documented RAM headroom rather than left at chart defaults.

#### Scenario: Happy path — pod scheduled within defined bounds

- **WHEN** the Loki pod is scheduled
- **THEN** it has non-empty `resources.requests` and `resources.limits` for both CPU and memory

#### Scenario: Error/rejection — no unbounded deployment

- **WHEN** the Helm values are reviewed
- **THEN** they SHALL NOT omit `resources`, leaving the pod unbounded against the shared node's budget

### Requirement: Loki accepts pushes on its native push API

Loki SHALL expose its push endpoint (`/loki/api/v1/push`) on its in-cluster Service, as the target for Alloy's log shipping — no gateway/proxy component in front of it.

#### Scenario: Happy path — Alloy's pushed logs are ingested

- **WHEN** Alloy pushes a batch of labeled log streams to Loki's in-cluster Service
- **THEN** Loki ingests them and they become queryable by their labels

#### Scenario: Contract — Service DNS name matches Alloy's configured endpoint

- **WHEN** Loki's in-cluster Service DNS name and the `alloy` Application's configured Loki write endpoint are compared
- **THEN** both SHALL resolve to the same Service
