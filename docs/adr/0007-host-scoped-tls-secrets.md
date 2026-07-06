# Host-scoped TLS secrets shared across Ingresses on the same host

Ingresses that share a host (e.g. multiple Services routing under different paths of `xdezex.duckdns.org`) reference the same TLS `secretName`, named after the host (`xdezex-duckdns-org-tls`) rather than the Service (`hello-tls`). This lets cert-manager's ingress-shim issue one `Certificate` per host regardless of how many Services route into it, avoiding duplicate ACME orders — and duplicate Let's Encrypt rate-limit consumption — for the same DNS name.

## Considered options

- **Per-service secretName** (e.g. `hello-tls`) — rejected: once a second Ingress shares the host, this forks what's logically one certificate into several, issued and renewed independently for the same domain.
