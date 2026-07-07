## ADDED Requirements

### Requirement: Tempo datasource is provisioned alongside Prometheus and Loki, via the same sidecar mechanism

A Tempo datasource SHALL be deployed as Observability config, the same way the existing Prometheus and Loki datasources are: a ConfigMap under `deploy/observability-config/grafana-datasource/`, discovered by Grafana's sidecar rather than requiring a hard sync-order dependency, independent of the `grafana` Application's own lifecycle.

#### Scenario: Happy path — datasource ConfigMap present and discovered

- **WHEN** the `grafana-datasource` Application is synced by ArgoCD
- **THEN** a ConfigMap containing the Tempo datasource definition exists in the `observability` namespace, and Grafana's sidecar makes it available without a manual restart

#### Scenario: Error/rejection — not folded into the grafana Application

- **WHEN** `deploy/apps/grafana.yaml`'s Helm values are reviewed
- **THEN** they SHALL NOT contain an inline Tempo `datasources` provisioning block; the datasource SHALL come from the separate `grafana-datasource` Application instead

#### Scenario: Contract — datasource URL matches Tempo's in-cluster Service

- **WHEN** the Tempo datasource ConfigMap's `url` and Tempo's in-cluster Service DNS name are compared
- **THEN** both SHALL resolve to the same Service, using the in-cluster Service DNS name rather than a pod IP, NodePort, or external address

### Requirement: Tempo datasource has no trace-to-logs/metrics correlation configured

The Tempo datasource definition SHALL NOT configure `tracesToLogs`, `tracesToMetrics`, or any other correlation field — that work is scoped to a separate follow-up (#87), not this change.

#### Scenario: Happy path — datasource works standalone

- **WHEN** a trace is viewed in Grafana via the Tempo datasource
- **THEN** trace search and span detail work without any correlated logs/metrics panel

#### Scenario: Error/rejection — no correlation fields present

- **WHEN** the Tempo datasource ConfigMap is reviewed
- **THEN** its `jsonData` SHALL NOT include `tracesToLogsV2`, `tracesToMetrics`, or equivalent correlation configuration
