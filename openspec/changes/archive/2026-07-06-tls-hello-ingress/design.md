## Context

The `letsencrypt-prod` `ClusterIssuer` (#46) is Ready in the cluster. `hello`'s Ingress (`deploy/services/hello/ingress.yaml`) currently serves plain HTTP only, and its spec explicitly forbids a `tls` block until this issue. This is the last link in #13's TLS chain: cert-manager install → ClusterIssuer → this change (Ingress annotation + `tls` block). Per exploration, multiple future Services are expected to share host `xdezex.duckdns.org` under different paths, which shapes the secret-naming decision below.

## Goals / Non-Goals

**Goals:**
- `hello` Ingress issues a valid Let's Encrypt certificate for `xdezex.duckdns.org` via cert-manager's ingress-shim (annotation-driven, no hand-authored `Certificate`)
- Certificate secret is named so it can be safely shared by future Ingresses on the same host, without duplicate certificate issuance for the same DNS name

**Non-Goals:**
- HTTP→HTTPS redirect — separate #13 task, tracked independently
- A hand-authored `Certificate` resource — the ingress-shim annotation is sufficient and is what #47's task list actually asks for
- Any change to `deploy/apps/hello.yaml` or the ArgoCD Application itself — this is a pure manifest edit inside the existing synced path

## Decisions

**Ingress-shim annotation, not a standalone `Certificate` resource.** cert-manager watches for `cert-manager.io/cluster-issuer` on any Ingress and creates the matching `Certificate` automatically. Issue #47's tasks name exactly this annotation plus a `tls`/`secretName` pair — not a `Certificate` YAML — so this avoids an extra file with no added control we need at this scope.
_Alternative considered_: author `deploy/services/hello/certificate.yaml` explicitly. Rejected — more files for identical behavior; revisit only if we need non-default fields (e.g. custom `duration`, `dnsNames` beyond the Ingress's own host).

**Host-scoped `secretName` (`xdezex-duckdns-org-tls`), not service-scoped (`hello-tls`).** Confirmed during exploration: other Services will share `xdezex.duckdns.org` under different paths. If each Ingress declared its own `tls` block with a distinct `secretName` for the same host, cert-manager would issue a separate `Certificate`/ACME order per Ingress for the same DNS name — wasted orders against Let's Encrypt's rate limits, and N secrets holding what's logically one certificate. Naming the secret after the host, and reusing it across every Ingress for that host, keeps it to one `Certificate` per DNS name regardless of how many Services route into it.
_Alternative considered_: `hello-tls`, scoped to this Service. Rejected — matches today's single-Ingress reality but breaks the moment a second Ingress for the same host exists, and renaming a live TLS secret later is needless churn.

**No redirect in this change.** Traefik doesn't redirect HTTP→HTTPS by default; that needs a `Middleware` + entrypoint config, which is a distinct #13 task. Adding it here would silently break the "plain HTTP still works" expectation the spec update leaves intact.

## Risks / Trade-offs

- **[Risk]** If `letsencrypt-prod` isn't actually `Ready` (e.g. #46 merged but never verified in-cluster), the `Certificate` cert-manager creates from the shim will sit pending and the Ingress will have no valid cert → **Mitigation**: verify `ClusterIssuer` status via `ssh miniser` before treating this change as syncable; tasks.md orders this check before the deploy-dependent verification steps.
- **[Risk]** A future Ingress author might not know the secret is intentionally shared and rename it to something service-scoped, silently forking the certificate → **Mitigation**: add a short comment in `ingress.yaml` next to `secretName` noting it's shared across hosts, not per-service.
- **[Risk]** HTTP-01 challenge requires port 80 reachable from the internet, same precondition as #46 — outside this change's control → **Mitigation**: already verified as part of #46; not re-litigated here.

## Migration Plan

1. Edit `deploy/services/hello/ingress.yaml`: add the `cert-manager.io/cluster-issuer: letsencrypt-prod` annotation and a `tls` block (`hosts: [xdezex.duckdns.org]`, `secretName: xdezex-duckdns-org-tls`).
2. Commit, merge, let ArgoCD sync.
3. Verify via `ssh miniser` that the `Certificate` cert-manager created reports `Ready: True` and the `xdezex-duckdns-org-tls` Secret exists in the `services` namespace.
4. Verify `https://xdezex.duckdns.org/hello` serves with a valid certificate from mobile data (the issue's literal "done when").
5. Rollback: revert the Ingress edit. cert-manager will leave the `Certificate`/Secret in place until garbage-collected or the Ingress annotation is removed; no destructive cleanup needed for a revert.

## Open Questions

None outstanding — secret-sharing scope and redirect deferral were both confirmed during exploration before this proposal was written.
