# grafana-datasource Specification

## Purpose
TBD - created by archiving change deploy-grafana. Update Purpose after archive.
## Requirements
### Requirement: Prometheus datasource is provisioned as its own Observability config item

The Prometheus datasource SHALL be deployed as Observability config: a ConfigMap under `deploy/observability-config/grafana-datasource/`, with its own ArgoCD Application (`deploy/apps/grafana-datasource.yaml`), independent of the `grafana` Application's lifecycle.

#### Scenario: Happy path — Application synced and datasource ConfigMap present

- **WHEN** the `grafana-datasource` Application is synced by ArgoCD
- **THEN** a ConfigMap containing the Prometheus datasource definition exists in the `observability` namespace

#### Scenario: Error/rejection — not folded into the grafana Application

- **WHEN** `deploy/apps/grafana.yaml`'s Helm values are reviewed
- **THEN** they SHALL NOT contain an inline `datasources` provisioning block; the datasource SHALL come from the separate `grafana-datasource` Application instead

#### Scenario: Contract — manifests are local, not a remote Helm chart

- **WHEN** the `grafana-datasource` Application spec is inspected
- **THEN** its `source` SHALL point at the local `deploy/observability-config/grafana-datasource/` path (kustomize), not a remote chart repo

### Requirement: Datasource ConfigMap is discovered via Grafana's sidecar, not synced atomically

Grafana SHALL be configured with `sidecar.datasources.enabled: true` so it discovers the datasource ConfigMap dynamically by label at runtime, rather than requiring the `grafana-datasource` Application to sync before or atomically with `grafana.yaml`.

#### Scenario: Happy path — datasource appears without a Grafana restart tied to sync order

- **WHEN** the `grafana-datasource` Application syncs after Grafana is already running
- **THEN** Grafana's sidecar detects the labeled ConfigMap and the Prometheus datasource becomes available without a manual Grafana restart

#### Scenario: Error/rejection — no hard startup dependency introduced

- **WHEN** `grafana.yaml` and `grafana-datasource.yaml`'s sync-wave annotations are compared
- **THEN** both SHALL be wave `"2"` with no explicit ordering between them, since the sidecar mechanism tolerates either syncing first

### Requirement: Datasource points at Prometheus's in-cluster Service

The datasource definition SHALL configure a Prometheus datasource whose URL is Prometheus's in-cluster Service DNS name (`http://prometheus-server.observability.svc.cluster.local`), matching the endpoint otel-collector already uses for `prometheusremotewrite`.

#### Scenario: Happy path — Grafana queries return live metrics

- **WHEN** a dashboard panel in Grafana queries this datasource for a metric hello has emitted
- **THEN** Grafana returns the metric's values from Prometheus

#### Scenario: Error/rejection — no external or hardcoded IP used

- **WHEN** the datasource ConfigMap is reviewed
- **THEN** its `url` field SHALL use the in-cluster Service DNS name, not a pod IP, NodePort, or external address

#### Scenario: Contract — datasource URL matches otel-collector's existing endpoint host

- **WHEN** the datasource ConfigMap's `url` and `deploy/apps/otel-collector.yaml`'s `prometheusremotewrite.endpoint` are compared
- **THEN** both SHALL resolve to the same Prometheus Service, `prometheus-server.observability.svc.cluster.local`

