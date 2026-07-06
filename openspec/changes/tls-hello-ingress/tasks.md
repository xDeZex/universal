## 1. hello Ingress requests a certificate via cert-manager's ingress-shim

- [x] 1.1 `deploy/services/hello/ingress.yaml` carries the `cert-manager.io/cluster-issuer: letsencrypt-prod` annotation
- [x] 1.2 `deploy/services/hello/ingress.yaml` has a `spec.tls` entry for host `xdezex.duckdns.org` with `secretName: xdezex-duckdns-org-tls`, plus a short comment noting the secret is host-scoped and shared across future Ingresses on this host, not per-service

## 2. Change is deployed and verified live (depends on task group 1 being merged and synced)

- [ ] 2.1 After merge, ArgoCD reports the `hello` Application synced and healthy with the updated Ingress
- [ ] 2.2 Via `ssh miniser`, the `letsencrypt-prod` `ClusterIssuer` reports `Ready: True` and the cert-manager `Certificate` for `xdezex.duckdns.org` reports `Ready: True`, with the `xdezex-duckdns-org-tls` Secret present in the `services` namespace
- [ ] 2.3 `https://xdezex.duckdns.org/hello` serves a valid certificate when checked from mobile data (issue #47's "done when")
