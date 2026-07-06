## Why

The hello Service is deployed and reachable in-cluster, but there's no route in from outside the LAN. Phase 0 isn't done until `git push` results in something reachable from the public internet — closes issue #10. The router-side prerequisites (static DHCP lease for the Beelink at `192.168.50.135`, DuckDNS pointed at the home IP, port forwards for 80 and 443) are already done manually outside this repo; the only remaining piece is routing the request once it reaches the cluster.

## What Changes

- Add a Kubernetes `Ingress` resource for hello, using k3s's bundled Traefik as the ingress controller (no separate Traefik install needed)
- Route `http://xdezex.duckdns.org/hello` to the existing `hello` ClusterIP Service on port 8080 (path-based routing, chosen over per-Service subdomains so future Services share the one host without extra DNS/cert bookkeeping)
- Register the new manifest in `deploy/services/hello/kustomization.yaml`
- Plain HTTP only — TLS is out of scope, deferred to issue #13

## Capabilities

### New Capabilities
- `hello-ingress`: External HTTP routing for the hello Service via k3s's bundled Traefik Ingress controller, path-based on the shared `xdezex.duckdns.org` host

### Modified Capabilities
(none — existing `hello-deployment` requirements, e.g. the ClusterIP Service, are unchanged; the Ingress adds a new route on top)

## Impact

- `deploy/services/hello/`: new `ingress.yaml`, updated `kustomization.yaml`
- No application code changes (hello's Go source and Dockerfile are untouched)
- No new cluster components — k3s ships Traefik by default
- Verification requires an external network check (e.g. from mobile data) since the router/DNS/port-forward setup lives outside git and can't be verified by CI
