# Per-component namespaces for Infra components

Infra components (Sealed Secrets, the DuckDNS updater) each get their own Kubernetes namespace, rather than sharing one `infra` namespace the way ADR 0004 groups backend Services into `services`. We decided this because Sealed Secrets' RBAC is unusually sensitive — it can decrypt any SealedSecret in the namespaces it watches — so a dedicated namespace bounds that blast radius at no added operational cost, since upstream's own manifests default to it anyway. ADR 0004's "isolation doesn't pay for itself yet" reasoning was scoped to Services we author ourselves, which are homogeneous and low-risk; it doesn't automatically extend to third-party components running with elevated privileges.

## Considered options

- **Shared `infra` namespace**, mirroring ADR 0004 — rejected: Sealed Secrets' RBAC scope makes namespace isolation a meaningful containment boundary here, not just tidiness, so the two situations aren't actually analogous.
