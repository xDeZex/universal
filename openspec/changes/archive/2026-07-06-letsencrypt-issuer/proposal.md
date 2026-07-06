## Why

cert-manager is installed and healthy in the cluster (#45), but nothing yet tells it how to obtain certificates. A `ClusterIssuer` for Let's Encrypt is the next required step in the TLS rollout (#13) before any `Certificate` can be requested for `xdezex.duckdns.org`.

## What Changes

- Add a `letsencrypt-issuer` ArgoCD Application (`deploy/apps/letsencrypt-issuer.yaml`), git-sourced from this repo, synced at `argocd.argoproj.io/sync-wave: "1"` so it applies only after cert-manager's CRDs and webhook (wave `0`) are up.
- Add `deploy/infra-config/letsencrypt-issuer/` with a `kustomization.yaml` (namespace `cert-manager`) and the `letsencrypt-prod` `ClusterIssuer` manifest — this is Infra config (configures the existing cert-manager Infra component; installs no new software), per `CONTEXT.md`.
- `ClusterIssuer` configuration:
  - ACME server: Let's Encrypt production (`https://acme-v02.api.letsencrypt.org/directory`)
  - Account email: `ollibolli.lillberg@gmail.com`
  - HTTP-01 solver via the `traefik` `IngressClass` (confirmed as the cluster's default ingress class)

## Capabilities

### New Capabilities
- `letsencrypt-issuer`: cluster-scoped `ClusterIssuer` for Let's Encrypt production, deployed as its own git-sourced ArgoCD Application at sync-wave `1`, using HTTP-01 validation via Traefik.

### Modified Capabilities
(none — cert-manager's existing spec already anticipates this dependent config; see `openspec/specs/cert-manager/spec.md` "Contract — installed before any dependent Infra config")

## Impact

- New files: `deploy/apps/letsencrypt-issuer.yaml`, `deploy/infra-config/letsencrypt-issuer/kustomization.yaml`, `deploy/infra-config/letsencrypt-issuer/clusterissuer.yaml`
- Depends on: cert-manager (#45) already synced and healthy
- Blocks: future `Certificate` request for `xdezex.duckdns.org` and the HTTPS ingress switch (remaining tasks of #13)
- Requires port 80 forwarded to Traefik on the router for the HTTP-01 challenge to complete (out-of-repo, previously flagged as a precondition)
