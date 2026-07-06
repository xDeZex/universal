## 1. hello is reachable externally via a path-based Ingress

- [x] 1.1 `deploy/services/hello/ingress.yaml` defines a `networking.k8s.io/v1` Ingress named `hello` in the `services` namespace, host `xdezex.duckdns.org`, path `/hello` (prefix), backend `hello` Service port 8080
- [x] 1.2 `deploy/services/hello/kustomization.yaml` lists `ingress.yaml` under `resources`
- [x] 1.3 `yamllint` passes on the new manifest

## 2. hello Ingress serves plain HTTP only

- [x] 2.1 The Ingress manifest has no `tls` block and no HTTPS redirect annotation

## 3. Verify external reachability

- [x] 3.1 After ArgoCD syncs, `http://xdezex.duckdns.org/hello` answers from outside the LAN (e.g. checked from mobile data), confirming router port forward, DuckDNS, and the Ingress rule all line up
- [x] 3.2 A request to an unmatched path on the same host (e.g. `/nonexistent`) returns 404 rather than hitting the `hello` Service
