## Why

Requests to `http://xdezex.duckdns.org/hello` are currently served in plaintext even though a valid Let's Encrypt certificate is already issued and `https://` works. This is the last unchecked task of #13 (TLS via cert-manager + Let's Encrypt) — closing it means every request into the cluster is forced onto TLS, not just the ones that happen to ask for it. Issue #48 tracks this as an independent follow-up (#45/#46/#47 already closed the cert-manager/ClusterIssuer/Ingress chain); it isn't blocked by, and doesn't block, any of them.

## What Changes

- Add a `HelmChartConfig` (`traefik`, `kube-system`) that patches k3s's bundled Traefik to redirect its `web` (port 80) entrypoint to `websecure` (port 443) with a permanent HTTPS redirect, applied host-wide rather than per-Ingress.
- New ArgoCD Application under `deploy/apps/` syncing this config into `kube-system`, following the same Infra config pattern ADR-0006 already establishes for `letsencrypt-issuer`.

## Capabilities

### New Capabilities
- `traefik-redirect`: Cluster-wide HTTP→HTTPS redirect behavior on the k3s-bundled Traefik entrypoint, configured as an infra-config (not owned by any single Service's Ingress).

### Modified Capabilities

(none — this doesn't change `hello-ingress` or any other existing spec's requirements; it changes what happens to a request before it reaches any Ingress rule)

## Impact

- **Affected**: `deploy/infra-config/traefik-redirect/` (new), `deploy/apps/traefik-redirect.yaml` (new)
- **Cluster-wide blast radius**: Traefik is the only ingress controller on this host — a malformed `HelmChartConfig` affects every Ingress, not just `hello`. No existing manifests are modified, only additive.
- **cert-manager HTTP-01 interaction**: `letsencrypt-prod`'s ACME solver (`deploy/infra-config/letsencrypt-issuer/clusterissuer.yaml`) validates over port 80 via `ingressClassName: traefik`. The redirect must not break certificate issuance/renewal — ACME validators follow HTTPS redirects per spec, but this is worth explicit verification after deploy (see design.md).
