# prometheus Specification

## Purpose
TBD - created by archiving change metrics-backend-prometheus. Update Purpose after archive.
## Requirements
### Requirement: Prometheus runs as an Observability component

Prometheus SHALL be installed via a dedicated ArgoCD Application (`deploy/apps/prometheus.yaml`) sourcing the upstream `prometheus-community/prometheus` Helm chart directly (server only — no Operator, no bundled Alertmanager/node-exporter/kube-state-metrics/Grafana, per ADR-0010), running in the shared `observability` namespace (ADR-0008).

#### Scenario: Happy path — Application synced and Prometheus healthy

- **WHEN** the `prometheus` Application is synced by ArgoCD
- **THEN** the Prometheus server pod runs in the `observability` namespace and reports healthy

#### Scenario: Error/rejection — no bundled components

- **WHEN** the Application's Helm values are reviewed
- **THEN** they SHALL NOT enable Alertmanager, node-exporter, kube-state-metrics, or any bundled Grafana that `kube-prometheus-stack` would otherwise provide

#### Scenario: Contract — Helm chart sourced directly, values forwarded correctly

- **WHEN** the ArgoCD Application spec is inspected
- **THEN** its `source` SHALL reference the upstream `prometheus-community/prometheus` Helm chart repo (not a git path of vendored manifests), and `helm.values` SHALL configure the server component only

### Requirement: Metrics are persisted with a bounded retention window

Prometheus's TSDB SHALL be backed by a PVC using the `observability-retain` StorageClass, with retention set to exactly 7 days.

#### Scenario: Happy path — data within retention is queryable

- **WHEN** a metric ingested less than 7 days ago is queried
- **THEN** Prometheus returns it

#### Scenario: Error/rejection — no unbounded retention

- **WHEN** the Helm values are reviewed
- **THEN** they SHALL NOT leave retention at an unbounded or default-forever setting; `--storage.tsdb.retention.time` (or chart equivalent) SHALL be set to `7d`

#### Scenario: Contract — PVC references the observability-retain StorageClass

- **WHEN** Prometheus's persistent volume configuration is inspected
- **THEN** its `storageClassName` SHALL be `observability-retain`, not the cluster's default `local-path` class

### Requirement: Resource requests/limits are set against the phase RAM budget

The Prometheus Deployment/StatefulSet SHALL specify explicit CPU/memory requests and limits, sized to fit within the Phase 1 epic's (#14) documented RAM headroom rather than left at chart defaults.

#### Scenario: Happy path — pod scheduled within defined bounds

- **WHEN** the Prometheus pod is scheduled
- **THEN** it has non-empty `resources.requests` and `resources.limits` for both CPU and memory

#### Scenario: Error/rejection — no unbounded deployment

- **WHEN** the Helm values are reviewed
- **THEN** they SHALL NOT omit `resources`, leaving the pod unbounded against the shared node's budget

### Requirement: Alert rule fires on hello's non-2xx response rate

Prometheus SHALL be configured with a native alerting rule (via `serverFiles."alerting_rules.yml"` in the Helm values), evaluating whether hello's non-2xx response rate is nonzero, with no Alertmanager involved (ADR-0010).

#### Scenario: Happy path — alert fires on a manually-triggered non-2xx response

- **WHEN** a non-GET request is sent to hello's root endpoint, producing a 405 response, and up to 5 minutes elapse
- **THEN** the rule transitions to `firing` in Prometheus's `/alerts` view

#### Scenario: Error/rejection — window sized against the push interval, not a scrape default

- **WHEN** the rule's `expr` is reviewed
- **THEN** its range-vector window SHALL be at least 4x hello's OTel export interval (60s default), not a short window borrowed from typical scrape-interval conventions (see `deploy/CLAUDE.md`)

#### Scenario: Contract — no Alertmanager wired

- **WHEN** the Prometheus Helm values are reviewed
- **THEN** `alertmanager.enabled` SHALL remain `false` and no `alerting.alertmanagers` target SHALL be configured; the rule fires and is visible directly in Prometheus without a notification hop
