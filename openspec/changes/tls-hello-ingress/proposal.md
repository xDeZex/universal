## Why

`hello` is currently only reachable over plain HTTP (issue #46/#13 closed the ClusterIssuer gap, so `letsencrypt-prod` is now Ready). Issue #47 finishes Phase 0's TLS work: the `hello` Ingress needs a `cert-manager.io/cluster-issuer` annotation and a `tls` block so cert-manager's ingress-shim issues and terms a real certificate for `xdezex.duckdns.org`, making `https://xdezex.duckdns.org/hello` serve with a valid cert from mobile data.

## What Changes

- Add `cert-manager.io/cluster-issuer: letsencrypt-prod` annotation to `deploy/services/hello/ingress.yaml`
- Add a `spec.tls` block to the same Ingress, referencing host `xdezex.duckdns.org` and a **host-scoped** `secretName` (e.g. `xdezex-duckdns-org-tls`) rather than a service-scoped one — future Services will share this same host under different paths, and a shared secret avoids cert-manager issuing duplicate certificates (and burning Let's Encrypt rate limits) for the same DNS name
- **BREAKING**: removes the existing "hello Ingress serves plain HTTP only" contract from the `hello-ingress` spec — HTTPS is now configured. Plain HTTP continues to work (no redirect yet); it's just no longer the *only* option.
- HTTP→HTTPS redirect stays explicitly out of scope — deferred to a later #13 task

## Capabilities

### New Capabilities

(none)

### Modified Capabilities

- `hello-ingress`: adds a TLS requirement (annotation + tls block, host-scoped secret) and removes the existing "plain HTTP only" requirement, since that's no longer true once this lands

## Impact

- `deploy/services/hello/ingress.yaml` — annotation + tls block added
- No new ArgoCD Application, no new Certificate resource (cert-manager's ingress-shim creates the `Certificate` automatically from the annotated Ingress)
- Depends on `letsencrypt-prod` `ClusterIssuer` (from #46) being `Ready` in-cluster before the Certificate can be issued
