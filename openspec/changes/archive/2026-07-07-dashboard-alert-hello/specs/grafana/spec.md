## MODIFIED Requirements

### Requirement: Grafana runs as an Observability component

Grafana SHALL be installed via a dedicated ArgoCD Application (`deploy/apps/grafana.yaml`) sourcing the upstream `grafana/grafana` Helm chart directly, running in the shared `observability` namespace (ADR-0008).

#### Scenario: Happy path — Application synced and Grafana healthy

- **WHEN** the `grafana` Application is synced by ArgoCD
- **THEN** the Grafana pod runs in the `observability` namespace and reports healthy

#### Scenario: Error/rejection — no bundled unrelated components

- **WHEN** the Application's Helm values are reviewed
- **THEN** they SHALL NOT enable any bundled sidecar or dependency beyond the datasource-provisioning and dashboard-provisioning sidecars this project's changes require

#### Scenario: Contract — Helm chart sourced directly, values forwarded correctly

- **WHEN** the ArgoCD Application spec is inspected
- **THEN** one of its `sources` entries SHALL reference the upstream `grafana/grafana` Helm chart repo (not a git path of vendored manifests), and `helm.values` SHALL configure the Grafana deployment
