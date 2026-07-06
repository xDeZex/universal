## ADDED Requirements

### Requirement: hello is reachable externally via a path-based Ingress

`deploy/services/hello/ingress.yaml` SHALL define a `networking.k8s.io/v1` `Ingress` named `hello` in the `services` namespace, routing host `xdezex.duckdns.org` path `/hello` (prefix) to the `hello` Service on port 8080, using k3s's bundled Traefik as the ingress controller.

#### Scenario: Happy path — external request reaches hello

- **WHEN** a client requests `http://xdezex.duckdns.org/hello` from outside the LAN
- **THEN** the router forwards port 80 to the Beelink, Traefik matches the Ingress rule, and the response comes from the `hello` Service

#### Scenario: Error/rejection — unmatched path

- **WHEN** a client requests a path other than `/hello` on `xdezex.duckdns.org` (e.g. `/nonexistent`)
- **THEN** Traefik returns 404 rather than routing the request to the `hello` Service

#### Scenario: Contract — no separate ingress controller install required

- **WHEN** the `hello` Ingress manifest is synced by ArgoCD
- **THEN** k3s's bundled Traefik picks it up automatically as the default `IngressClass`, with no additional controller installed via `deploy/apps/`

---

### Requirement: hello Ingress serves plain HTTP only

The `hello` Ingress SHALL NOT configure a `tls` block or any HTTPS redirect; external access is plain HTTP until issue #13 adds cert-manager and TLS.

#### Scenario: Happy path — plain HTTP served without redirect

- **WHEN** a client requests `http://xdezex.duckdns.org/hello`
- **THEN** Traefik serves the response directly over HTTP with no redirect to HTTPS

#### Scenario: Error/rejection — HTTPS not yet available

- **WHEN** a client requests `https://xdezex.duckdns.org/hello` before issue #13 lands
- **THEN** the request fails at the TLS handshake, since no certificate is configured for this host
