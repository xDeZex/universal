## ADDED Requirements

### Requirement: cert-manager runs as an Infra component via Helm source

cert-manager SHALL be installed via a dedicated ArgoCD Application (`deploy/apps/cert-manager.yaml`) whose source is the upstream Helm chart at `https://charts.jetstack.io`, running in its own `cert-manager` namespace (not shared with backend Services or other Infra components), synced at `argocd.argoproj.io/sync-wave: "0"`.

#### Scenario: Happy path — controller installed and healthy

- **WHEN** the `cert-manager` Application is synced by ArgoCD
- **THEN** the controller, webhook, and cainjector all run in the `cert-manager` namespace and report healthy

#### Scenario: Error/rejection — not vendored as a flattened manifest

- **WHEN** the Application's manifests are reviewed
- **THEN** they SHALL NOT be a raw/flattened static manifest copied into `deploy/infra/cert-manager/`; the source SHALL remain a live Helm chart reference so version bumps stay a one-line `targetRevision` change

#### Scenario: Contract — installed before any dependent Infra config

- **WHEN** any Infra config depends on cert-manager's CRDs or webhook (e.g. a `ClusterIssuer`)
- **THEN** that Infra config's Application sync-wave SHALL be greater than `0`, so cert-manager is already healthy by the time it is applied

### Requirement: CRDs are installed and lifecycle-managed by the same Application

The Helm release SHALL set `installCRDs: true` so cert-manager's CRDs (`Certificate`, `Issuer`, `ClusterIssuer`, etc.) are installed and upgraded by the same Application, with no separate manual `kubectl apply` step.

#### Scenario: Happy path — CRDs registered on sync

- **WHEN** the `cert-manager` Application is synced for the first time
- **THEN** the `certificates.cert-manager.io`, `issuers.cert-manager.io`, and `clusterissuers.cert-manager.io` CRDs (among others) are registered in the cluster

#### Scenario: Error/rejection — no manual CRD step

- **WHEN** the Application's Helm values are reviewed
- **THEN** they SHALL NOT rely on a separate `kubectl apply -f` step or documented manual CRD install; `installCRDs: true` SHALL be the only mechanism

#### Scenario: Contract — Helm values set installCRDs

- **WHEN** the ArgoCD Application's Helm `values` are inspected
- **THEN** `installCRDs: true` SHALL be present
