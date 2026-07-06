# traefik-redirect Specification

## Purpose
TBD - created by archiving change traefik-https-redirect. Update Purpose after archive.
## Requirements
### Requirement: Traefik redirect is deployed as its own git-sourced Application

A `HelmChartConfig` named `traefik` in the `kube-system` namespace SHALL be deployed via a dedicated ArgoCD Application (`deploy/apps/traefik-redirect.yaml`), git-sourced from this repo at `deploy/infra-config/traefik-redirect/` (Infra config, per ADR-0006 — it configures k3s's bundled Traefik, a platform-provided controller, not an Infra component this repo installs), targeting the `kube-system` namespace. It carries no `sync-wave` annotation, matching the precedent set by other Applications with no ordering dependency (e.g. `hello.yaml`) — nothing in the cert-manager/issuer chain depends on this redirect, and it doesn't depend on them either.

#### Scenario: Happy path — HelmChartConfig merges into the bundled Traefik release

- **WHEN** the `traefik-redirect` Application is synced by ArgoCD
- **THEN** k3s's helm-controller merges the `HelmChartConfig`'s `valuesContent` into the existing `traefik` HelmChart release in `kube-system`, without requiring the `traefik` HelmChart itself to be redeployed by this repo

#### Scenario: Error/rejection — not vendored as a flattened patch bundled with another Application

- **WHEN** the Application's manifests are reviewed
- **THEN** the `HelmChartConfig` SHALL live under its own `deploy/infra-config/traefik-redirect/` path with its own `kustomization.yaml`, not appended into `deploy/apps/cert-manager.yaml`, `deploy/apps/letsencrypt-issuer.yaml`, or any Service's manifests

#### Scenario: Contract — namespace and name match the HelmChart being patched

- **WHEN** the `traefik-redirect` Application manifest and its `HelmChartConfig` are inspected
- **THEN** the `HelmChartConfig`'s `metadata.name` SHALL be `traefik` and `metadata.namespace` SHALL be `kube-system`, exactly matching the `HelmChart` resource k3s creates for its bundled Traefik, and the Application's `destination.namespace` SHALL be `kube-system`

### Requirement: HTTP requests on the web entrypoint are redirected to HTTPS

Traefik's `web` entrypoint (port 80) SHALL issue a permanent redirect to the `websecure` entrypoint (port 443) with scheme `https`, applied globally across every Ingress on the host rather than configured per-Ingress.

#### Scenario: Happy path — plaintext request redirected

- **WHEN** a client requests `http://xdezex.duckdns.org/hello`
- **THEN** Traefik responds with a permanent redirect (301/308) to `https://xdezex.duckdns.org/hello`

#### Scenario: Error/rejection — new Ingresses don't need to opt in individually

- **WHEN** a new Ingress is added to the cluster without any redirect-specific annotation
- **THEN** plaintext requests to that Ingress's host are still redirected to HTTPS, because the redirect is configured on the entrypoint, not on the Ingress resource

#### Scenario: Contract — ACME HTTP-01 challenges still validate after the redirect is live

- **WHEN** cert-manager's `letsencrypt-prod` issuer creates a temporary HTTP-01 solver Ingress and Let's Encrypt's validator requests the challenge path over port 80
- **THEN** the validator follows the redirect to `https` and the challenge SHALL still validate successfully, so existing certificate issuance/renewal (per the `letsencrypt-issuer` capability) is not broken by this change

