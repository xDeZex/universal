## Context

hello runs in-cluster with a ClusterIP Service but nothing routes external traffic to it. k3s ships Traefik by default, so exposing hello is a routing decision (what Ingress rule to write), not an infrastructure decision (no new component to install). The router-side prerequisites — static lease for the Beelink at `192.168.50.135`, DuckDNS pointed at the home IP, port forwards for 80 and 443 — are already in place, done manually outside git.

## Goals / Non-Goals

**Goals:**
- Route `http://xdezex.duckdns.org/hello` to the `hello` Service from outside the LAN
- Keep the manifest boring and consistent with the rest of `deploy/` (plain `networking.k8s.io/v1` Ingress, no Traefik-specific CRDs)

**Non-Goals:**
- TLS/HTTPS — deferred to issue #13 (cert-manager + Let's Encrypt)
- Automating DuckDNS refresh — that's issue #12; DuckDNS is already pointing correctly by hand
- Any DNS/router configuration — static lease, DuckDNS record, and port forwards are already done and out of this change's scope entirely

## Decisions

**Path-based routing on one shared host, not per-Service subdomains.** Considered `hello.xdezex.duckdns.org` (subdomain per Service) vs `xdezex.duckdns.org/hello` (path prefix on one host). Chose path-based: it's what issue #10 already specifies, and it keeps future Services on one host with no extra DNS bookkeeping. Subdomains would have worked too (DuckDNS resolves any label under the registered name to the same IP), but would cost one extra Let's Encrypt cert per Service once #13 lands, for no real benefit at this scale. Revisit if path collisions become annoying as more Services are added.

**No `ingressClassName` pinned explicitly.** k3s installs Traefik as the cluster's only/default `IngressClass`, so the Ingress can omit `ingressClassName` and still resolve unambiguously. If a second ingress controller is ever added, this manifest will need updating — acceptable, since that's speculative and not a current constraint.

## Risks / Trade-offs

- **Manual DuckDNS/port-forward state isn't visible in git.** If the home IP changes before #12 automates the DuckDNS refresh, external reachability breaks silently with no in-repo signal. Mitigated by #12 being next in the epic; not this change's problem to solve.
- **No automated verification of external reachability.** CI can confirm the manifest applies and ArgoCD syncs it, but "reachable from the public internet" can only be checked manually (e.g. from mobile data). This is a live check, not a test suite addition.
