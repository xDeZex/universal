# observability-storage Specification

## Purpose
TBD - created by archiving change metrics-backend-prometheus. Update Purpose after archive.
## Requirements
### Requirement: observability-retain StorageClass extends the platform's local-path provisioner with a Retain policy

The `observability-retain` StorageClass SHALL use the same `rancher.io/local-path` provisioner as the cluster's default StorageClass, but with `reclaimPolicy: Retain` instead of `Delete`. It SHALL be deployed as Observability config: manifests under `deploy/observability-config/storage/`, with its own ArgoCD Application under `deploy/apps/`.

#### Scenario: Happy path — Application synced and StorageClass available

- **WHEN** the observability-storage Application is synced by ArgoCD
- **THEN** the `observability-retain` StorageClass exists and is usable by any PVC in the `observability` namespace

#### Scenario: Error/rejection — no new provisioner introduced

- **WHEN** the StorageClass manifest is reviewed
- **THEN** its `provisioner` SHALL be `rancher.io/local-path`, matching the cluster default — no new CSI driver or provisioner SHALL be installed for this

#### Scenario: Contract — manifests are local, not a remote Helm chart

- **WHEN** the ArgoCD Application spec is inspected
- **THEN** its `source` SHALL point at the local `deploy/observability-config/storage/` path (kustomize), not a remote chart repo

### Requirement: observability-retain is not the cluster-wide default StorageClass

The `observability-retain` StorageClass SHALL remain scoped to explicit opt-in by observability components; it SHALL NOT become the cluster's default StorageClass.

#### Scenario: Happy path — cluster default is unchanged

- **WHEN** cluster StorageClasses are listed
- **THEN** `local-path` (the k3s built-in) remains the only class annotated as default

#### Scenario: Error/rejection — default annotation not set

- **WHEN** the `observability-retain` StorageClass manifest is reviewed
- **THEN** it SHALL NOT set the `storageclass.kubernetes.io/is-default-class` annotation to `"true"`
