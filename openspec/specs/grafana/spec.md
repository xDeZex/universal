# grafana Specification

## Purpose
TBD - created by archiving change deploy-grafana. Update Purpose after archive.
## Requirements
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

### Requirement: Grafana Application bundles its admin-credential SealedSecret via multi-source

The `grafana` Application SHALL use ArgoCD's multi-source `sources` list, combining the `grafana/grafana` chart source with a second source pointing at a local git path containing the admin-password SealedSecret, so the secret and the chart-rendered Deployment are managed by one Application.

#### Scenario: Happy path — secret and chart both sync from one Application

- **WHEN** the `grafana` Application is synced
- **THEN** both the chart-rendered resources and the SealedSecret from the local git path are applied as part of the same Application

#### Scenario: Error/rejection — no separate Application for the secret

- **WHEN** `deploy/apps/` is listed
- **THEN** there SHALL NOT be a separate Application dedicated solely to the Grafana admin-credential SealedSecret

#### Scenario: Contract — second source points at the local git path, not another chart

- **WHEN** the `grafana` Application's `sources` list is inspected
- **THEN** the second entry SHALL reference this repository's own `repoURL` and a local path under `deploy/observability-config/`, not a remote chart

### Requirement: Grafana is reachable externally via a path-based Ingress

Grafana's chart-native `ingress` values SHALL define a rule for host `xdezex.duckdns.org`, path `/grafana` (prefix), routing to the Grafana Service, reusing the shared `xdezex-duckdns-org-tls` secret (ADR-0007) rather than a Grafana-specific certificate.

#### Scenario: Happy path — external request reaches Grafana

- **WHEN** a client requests `https://xdezex.duckdns.org/grafana` from outside the LAN
- **THEN** Traefik terminates TLS using the shared certificate and routes the request to the Grafana Service, which responds with the login page

#### Scenario: Error/rejection — unmatched path

- **WHEN** a client requests a path other than `/grafana` on `xdezex.duckdns.org`
- **THEN** Traefik does not route the request to the Grafana Service

#### Scenario: Contract — TLS secret is the shared host secret, not a new one

- **WHEN** the Grafana Ingress's `tls` block is inspected
- **THEN** its `secretName` SHALL be `xdezex-duckdns-org-tls`, the same secret `hello`'s Ingress uses, and no new `Certificate` or ACME issuance SHALL be triggered for this host

### Requirement: Grafana serves correctly from a URL subpath

Grafana SHALL be configured with `server.root_url` set to `https://xdezex.duckdns.org/grafana` and `server.serve_from_sub_path` set to `true`, so links, redirects, and static assets resolve correctly when served under `/grafana` rather than the domain root.

#### Scenario: Happy path — login redirect stays under the subpath

- **WHEN** a client requests `https://xdezex.duckdns.org/grafana` and is redirected to the login page
- **THEN** the redirect target and all asset URLs are prefixed with `/grafana`, not the domain root

#### Scenario: Error/rejection — subpath serving not left unconfigured

- **WHEN** the Grafana Helm values are reviewed
- **THEN** `server.serve_from_sub_path` SHALL NOT be left at its chart default of `false` given the Ingress routes a non-root path

### Requirement: Anonymous access and self-signup are disabled

Grafana SHALL be configured with `auth.anonymous.enabled: false` and `users.allow_sign_up: false`, explicitly set rather than relying on chart or upstream defaults, since the instance is publicly reachable.

#### Scenario: Happy path — unauthenticated request requires login

- **WHEN** an unauthenticated client requests any dashboard or data view
- **THEN** Grafana redirects to the login page rather than serving content anonymously

#### Scenario: Error/rejection — no self-service account creation

- **WHEN** a client visits Grafana's sign-up flow
- **THEN** Grafana SHALL NOT allow a new account to be created through it

#### Scenario: Contract — values set explicitly, not inherited from defaults

- **WHEN** the Grafana Helm values are reviewed
- **THEN** `auth.anonymous.enabled` and `users.allow_sign_up` SHALL both be explicitly present and set to `false`, not omitted

### Requirement: Admin credentials are sourced from a SealedSecret

Grafana's admin account SHALL use `admin.existingSecret` pointing at a SealedSecret-derived Secret containing both the `admin-user` and `admin-password` keys, following the same SealedSecret pattern as `duckdns-updater`, rather than a chart-generated or default password. The chart's `_pod.tpl` sources both `GF_SECURITY_ADMIN_USER` and `GF_SECURITY_ADMIN_PASSWORD` from `admin.existingSecret` once it is set, so there is no plain-value path for the username independent of the secret.

#### Scenario: Happy path — admin logs in with the sealed password

- **WHEN** the admin authenticates at the Grafana login page using the username and password decrypted from the SealedSecret
- **THEN** login succeeds and the admin account has full privileges

#### Scenario: Error/rejection — no plaintext password committed

- **WHEN** the repository is reviewed
- **THEN** no manifest SHALL contain the Grafana admin username or password in plaintext; only the SealedSecret's encrypted form SHALL be committed

#### Scenario: Contract — chart references the existing Secret, not a generated one

- **WHEN** the Grafana Helm values are inspected
- **THEN** `admin.existingSecret` SHALL reference the Secret rendered from this change's SealedSecret (containing both `admin-user` and `admin-password` keys), and the chart SHALL NOT be left to auto-generate or default the admin username or password

### Requirement: Grafana runs without persistent storage

Grafana SHALL run with `persistence.enabled: false`, so its dashboard/user database does not survive pod restarts.

#### Scenario: Happy path — pod restarts without a PVC

- **WHEN** the Grafana pod is deleted and rescheduled
- **THEN** it starts successfully without waiting on or mounting any PersistentVolumeClaim

#### Scenario: Error/rejection — no PVC created for this change

- **WHEN** PersistentVolumeClaims in the `observability` namespace are listed
- **THEN** none SHALL be owned by the `grafana` Application

### Requirement: Resource requests/limits are set against the phase RAM budget

The Grafana Deployment SHALL specify explicit CPU/memory requests and limits (100m/128Mi request, 500m/256Mi limit), sized to fit within the Phase 1 epic's (#14) documented RAM headroom rather than left at chart defaults.

#### Scenario: Happy path — pod scheduled within defined bounds

- **WHEN** the Grafana pod is scheduled
- **THEN** it has non-empty `resources.requests` and `resources.limits` for both CPU and memory

#### Scenario: Error/rejection — no unbounded deployment

- **WHEN** the Helm values are reviewed
- **THEN** they SHALL NOT omit `resources`, leaving the pod unbounded against the shared node's budget

