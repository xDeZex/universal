## ADDED Requirements

### Requirement: Loki datasource is provisioned alongside Prometheus, via the same sidecar mechanism

A Loki datasource SHALL be deployed as Observability config, the same way the existing Prometheus datasource is: a ConfigMap under `deploy/observability-config/grafana-datasource/`, discovered by Grafana's sidecar rather than requiring a hard sync-order dependency, independent of the `grafana` Application's own lifecycle.

#### Scenario: Happy path — datasource ConfigMap present and discovered

- **WHEN** the `grafana-datasource` Application is synced by ArgoCD
- **THEN** a ConfigMap containing the Loki datasource definition exists in the `observability` namespace, and Grafana's sidecar makes it available without a manual restart

#### Scenario: Error/rejection — not folded into the grafana Application

- **WHEN** `deploy/apps/grafana.yaml`'s Helm values are reviewed
- **THEN** they SHALL NOT contain an inline Loki `datasources` provisioning block; the datasource SHALL come from the separate `grafana-datasource` Application instead

#### Scenario: Contract — datasource URL matches Loki's in-cluster Service

- **WHEN** the Loki datasource ConfigMap's `url` and Loki's in-cluster Service DNS name are compared
- **THEN** both SHALL resolve to the same Service, using the in-cluster Service DNS name rather than a pod IP, NodePort, or external address
