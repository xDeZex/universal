## ADDED Requirements

### Requirement: letsencrypt-prod ClusterIssuer is deployed as its own git-sourced Application

A `ClusterIssuer` named `letsencrypt-prod` SHALL be deployed via a dedicated ArgoCD Application (`deploy/apps/letsencrypt-issuer.yaml`), git-sourced from this repo at `deploy/infra-config/letsencrypt-issuer/` (Infra config, per `CONTEXT.md` — it configures the existing cert-manager Infra component and installs no new software), targeting the `cert-manager` namespace, synced at `argocd.argoproj.io/sync-wave: "1"` so it applies only after cert-manager's CRDs and webhook (wave `0`) are healthy.

#### Scenario: Happy path — issuer becomes Ready after cert-manager is healthy

- **WHEN** the `letsencrypt-issuer` Application is synced by ArgoCD after the `cert-manager` Application (wave `0`) is already healthy
- **THEN** the `letsencrypt-prod` `ClusterIssuer` is created in the cluster and reports `Ready: True`

#### Scenario: Error/rejection — not vendored as a flattened manifest bundled with cert-manager

- **WHEN** the Application's manifests are reviewed
- **THEN** the `ClusterIssuer` SHALL live under its own `deploy/infra-config/letsencrypt-issuer/` path with its own `kustomization.yaml`, not appended into `deploy/apps/cert-manager.yaml` or its Helm values

#### Scenario: Contract — sync-wave ordering relative to cert-manager

- **WHEN** the `letsencrypt-issuer` Application manifest is inspected
- **THEN** it SHALL carry `argocd.argoproj.io/sync-wave: "1"`, a value greater than cert-manager's wave `0`

### Requirement: ACME account uses the Let's Encrypt production server via HTTP-01 over Traefik

The `letsencrypt-prod` `ClusterIssuer` SHALL register its ACME account against `https://acme-v02.api.letsencrypt.org/directory` with contact email `ollibolli.lillberg@gmail.com`, and SHALL solve challenges using HTTP-01 via the cluster's `traefik` `IngressClass`.

#### Scenario: Happy path — HTTP-01 challenge solved via Traefik

- **WHEN** a `Certificate` referencing `letsencrypt-prod` triggers an ACME order
- **THEN** cert-manager creates a temporary solver `Ingress` with `ingressClassName: traefik`, and Traefik routes the ACME challenge request to it

#### Scenario: Error/rejection — challenge fails without port 80 reachable

- **WHEN** the HTTP-01 challenge path is not reachable from the internet (e.g. port 80 not forwarded to Traefik)
- **THEN** the ACME order SHALL remain pending/fail validation rather than the `ClusterIssuer` silently reporting `Ready`

#### Scenario: Contract — account key stored in the cert-manager namespace

- **WHEN** the ACME account is first registered
- **THEN** cert-manager SHALL store the account private key as a `Secret` in the `cert-manager` namespace (cert-manager's cluster resource namespace), referenced by the `ClusterIssuer`'s `privateKeySecretRef`
