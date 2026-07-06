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

### Requirement: hello Ingress terminates TLS via cert-manager ingress-shim

`deploy/services/hello/ingress.yaml` SHALL carry the `cert-manager.io/cluster-issuer: letsencrypt-prod` annotation and a `spec.tls` entry for host `xdezex.duckdns.org` referencing a host-scoped `secretName` (not a service-scoped one), so cert-manager's ingress-shim issues and stores a certificate for that host without a hand-authored `Certificate` resource.

#### Scenario: Happy path — HTTPS request served with a valid certificate

- **WHEN** a client requests `https://xdezex.duckdns.org/hello` from outside the LAN
- **THEN** Traefik terminates TLS using the certificate stored in the Ingress's `secretName`, and the response comes from the `hello` Service

#### Scenario: Error/rejection — issuer not yet Ready

- **WHEN** the `letsencrypt-prod` `ClusterIssuer` is not `Ready` at sync time
- **THEN** cert-manager's Certificate for this host SHALL remain pending rather than the Ingress silently falling back to an invalid or self-signed certificate

#### Scenario: Contract — secret is host-scoped, not service-scoped

- **WHEN** another Service later adds an Ingress for a different path under the same host `xdezex.duckdns.org`
- **THEN** its `tls` block SHALL reference the same `secretName` used here, so cert-manager issues one certificate per host rather than duplicate certificates for the same DNS name
