## ADDED Requirements

### Requirement: Sealed Secrets controller runs as an Infra component

The Bitnami Sealed Secrets controller SHALL be installed via a dedicated ArgoCD Application (`deploy/apps/sealed-secrets.yaml`) sourcing raw manifests vendored under `deploy/infra/sealed-secrets/`, running in its own `sealed-secrets` namespace (not shared with backend Services), and synced at `argocd.argoproj.io/sync-wave: "0"`.

#### Scenario: Happy path — controller installed and healthy

- **WHEN** the `sealed-secrets` Application is synced by ArgoCD
- **THEN** the controller runs in the `sealed-secrets` namespace and reports healthy, ready to watch for `SealedSecret` resources

#### Scenario: Error/rejection — no shared namespace with Services

- **WHEN** the controller's manifests are reviewed
- **THEN** they SHALL NOT place any resource in the `services` namespace, keeping the controller's RBAC scope isolated per ADR 0005

#### Scenario: Contract — installed before any dependent SealedSecret

- **WHEN** any other Application defines a `SealedSecret` resource
- **THEN** that Application's sync-wave SHALL be greater than `0`, so the `SealedSecret` CRD is already registered by the time it is applied

---

### Requirement: Controller private key backup is documented and off-git

The controller's private key SHALL NOT be committed to git. A runbook at `docs/runbooks/sealed-secrets-key-backup.md` SHALL document exporting the key, encrypting it locally with `age`, and storing only the encrypted blob outside the cluster.

#### Scenario: Happy path — key recoverable after cluster rebuild

- **WHEN** following the runbook's restore procedure against a fresh cluster
- **THEN** the previously backed-up key can be decrypted and applied before the controller starts, so existing SealedSecrets remain decryptable

#### Scenario: Error/rejection — plaintext key never leaves the cluster unencrypted

- **WHEN** the backup procedure is followed
- **THEN** no plaintext copy of the key is stored anywhere outside the cluster; only the `age`-encrypted file is retained, and local plaintext copies are deleted after upload
