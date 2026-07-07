## ADDED Requirements

### Requirement: Hello dashboard is provisioned as its own Observability config item

The hello dashboard SHALL be deployed as Observability config: a ConfigMap under `deploy/observability-config/grafana-dashboard-hello/`, with its own ArgoCD Application (`deploy/apps/grafana-dashboard-hello.yaml`), independent of the `grafana` Application's lifecycle.

#### Scenario: Happy path — Application synced and dashboard ConfigMap present

- **WHEN** the `grafana-dashboard-hello` Application is synced by ArgoCD
- **THEN** a ConfigMap containing the hello dashboard JSON exists in the `observability` namespace

#### Scenario: Error/rejection — not folded into the grafana Application

- **WHEN** `deploy/apps/grafana.yaml`'s Helm values are reviewed
- **THEN** they SHALL NOT contain an inline dashboard-provisioning block; the dashboard SHALL come from the separate `grafana-dashboard-hello` Application instead

#### Scenario: Contract — manifests are local, not a remote Helm chart

- **WHEN** the `grafana-dashboard-hello` Application spec is inspected
- **THEN** its `source` SHALL point at the local `deploy/observability-config/grafana-dashboard-hello/` path (kustomize), not a remote chart repo

### Requirement: Dashboard ConfigMap is discovered via Grafana's sidecar, not synced atomically

Grafana SHALL be configured with `sidecar.dashboards.enabled: true` so it discovers the dashboard ConfigMap dynamically by label at runtime, rather than requiring the `grafana-dashboard-hello` Application to sync before or atomically with `grafana.yaml`.

#### Scenario: Happy path — dashboard appears without a Grafana restart tied to sync order

- **WHEN** the `grafana-dashboard-hello` Application syncs after Grafana is already running
- **THEN** Grafana's sidecar detects the labeled ConfigMap and the hello dashboard becomes available without a manual Grafana restart

#### Scenario: Error/rejection — no hard startup dependency introduced

- **WHEN** `grafana.yaml` and `grafana-dashboard-hello.yaml`'s sync-wave annotations are compared
- **THEN** both SHALL be wave `"2"` with no explicit ordering between them, since the sidecar mechanism tolerates either syncing first

#### Scenario: Contract — ConfigMap carries the sidecar's discovery label

- **WHEN** the dashboard ConfigMap is inspected
- **THEN** it SHALL carry the label `grafana_dashboard: "1"`, matching the label Grafana's dashboard sidecar is configured to watch

### Requirement: Dashboard visualizes hello's request rate, latency, and error rate

The dashboard SHALL include three panels querying `job="hello"` series: request rate broken out by `http_response_status_code`, p50/p95 latency via `histogram_quantile` over `http_server_request_duration_seconds_bucket`, and a non-2xx response rate panel.

#### Scenario: Happy path — panels render live data

- **WHEN** the dashboard is opened in Grafana after hello has served at least one request
- **THEN** all three panels display data sourced from the `Prometheus` datasource

#### Scenario: Error/rejection — no route-dimension panel

- **WHEN** the dashboard JSON is reviewed
- **THEN** it SHALL NOT break any panel out by `http_route`, since hello serves only one instrumented route today

#### Scenario: Contract — non-2xx panel matches the alerting rule's expression

- **WHEN** the dashboard's non-2xx panel query and the Prometheus alerting rule's `expr` (see `prometheus` capability) are compared
- **THEN** both SHALL use the same underlying `http_response_status_code!~"2.."` condition over the same metric, so the dashboard visibly reflects the alert's own trigger condition
