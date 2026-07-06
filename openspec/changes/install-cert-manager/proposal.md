## Why

Phase 0 ends when `https://xdezex.duckdns.org/hello` serves with a valid certificate (issue #13). That requires cert-manager running in the cluster first — everything downstream (the Let's Encrypt ClusterIssuer in #46, TLS on hello's ingress in #47) depends on cert-manager's CRDs and webhook being installed and healthy. This change covers only the install.

## What Changes

- cert-manager installed as an Infra component via a new ArgoCD Application (`deploy/apps/cert-manager.yaml`)
- Application source is the upstream Helm chart (`https://charts.jetstack.io`), not a vendored/flattened manifest — a deliberate break from the `sealed-secrets` precedent, since cert-manager's release manifest is an order of magnitude larger and Helm keeps version bumps to a one-line `targetRevision` change
- Helm values set `installCRDs: true` so CRDs are managed by the same Application, no separate `kubectl apply` step
- Runs in its own `cert-manager` namespace, synced at `argocd.argoproj.io/sync-wave: "0"` so any dependent Infra config (the ClusterIssuer in #46) can rely on it already being healthy at wave `"1"`

## Capabilities

### New Capabilities
- `cert-manager`: cert-manager installed and running as an Infra component, ready for a ClusterIssuer to be layered on top in a later change

### Modified Capabilities
(none)

## Impact

- New: `deploy/apps/cert-manager.yaml` (ArgoCD Application, Helm source)
- New namespace: `cert-manager`
- No changes to existing Services, ingresses, or other Infra components
- Unblocks #46 (ClusterIssuer) and transitively #47 (TLS on hello) and #13
