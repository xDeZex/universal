## ADDED Requirements

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

## REMOVED Requirements

### Requirement: hello Ingress serves plain HTTP only

**Reason**: Superseded by TLS support — the `letsencrypt-prod` ClusterIssuer (#46) is Ready, so #47 adds the annotation and `tls` block this requirement previously prohibited.
**Migration**: None required. Plain HTTP continues to work unredirected (no HTTP→HTTPS redirect is added by this change); HTTPS is now also available.

The `hello` Ingress SHALL NOT configure a `tls` block or any HTTPS redirect; external access is plain HTTP until issue #13 adds cert-manager and TLS.

#### Scenario: Happy path — plain HTTP served without redirect

- **WHEN** a client requests `http://xdezex.duckdns.org/hello`
- **THEN** Traefik serves the response directly over HTTP with no redirect to HTTPS

#### Scenario: Error/rejection — HTTPS not yet available

- **WHEN** a client requests `https://xdezex.duckdns.org/hello` before issue #13 lands
- **THEN** the request fails at the TLS handshake, since no certificate is configured for this host
