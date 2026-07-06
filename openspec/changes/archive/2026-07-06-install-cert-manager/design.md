## Context

Phase 0's last task (#13) needs TLS on `hello`. That chain is cert-manager (this change) → a `letsencrypt-prod` ClusterIssuer (#46, an Infra config per `CONTEXT.md`) → the `tls:` block on hello's ingress (#47). This design covers only the cert-manager install — the first, foundational piece.

Every existing Infra component (`sealed-secrets`, `duckdns-updater`) is vendored as a flattened, static manifest committed under `deploy/infra/<name>/`, per the pattern in ADR 0002. cert-manager doesn't fit that pattern well: its release manifest bundles CRDs, the controller, webhook, and cainjector, and is roughly an order of magnitude larger than `sealed-secrets`' ~400 lines. This design deliberately diverges from the vendoring precedent in favor of an ArgoCD-native Helm source.

## Goals / Non-Goals

**Goals:**
- cert-manager installed, healthy, and synced by ArgoCD with no manual `kubectl apply` step
- CRDs lifecycle-managed by the same Application (no separate CRD install/upgrade step)
- Positioned (namespace, sync-wave) so #46's ClusterIssuer can depend on it deterministically

**Non-Goals:**
- The `ClusterIssuer` itself (#46)
- Any change to hello's ingress (#47)
- The global Traefik HTTP→HTTPS redirect (#48) — unrelated to cert-manager, tracked separately

## Decisions

**Helm source over vendored manifest.** ArgoCD supports a Helm chart repository directly as an `Application.spec.source` (`repoURL: https://charts.jetstack.io`, `chart: cert-manager`, `targetRevision: <pinned version>`), rendered server-side at sync time — no chart is committed to this repo. Trade-off: this is the first Infra component in the repo that isn't a flattened static manifest, so it reads as an exception to the `sealed-secrets` precedent. That inconsistency is captured explicitly in the spec's "Error/rejection" scenario (manifests SHALL NOT be vendored as a flattened copy) so it reads as deliberate, not an oversight.
_Alternative considered_: `helm template` the release once and commit the flattened output, matching `sealed-secrets` exactly. Rejected — cert-manager's upstream chart is updated far more often than Sealed Secrets, and repeating the sealed-secrets manual-flatten process for every patch release isn't worth the consistency.

**`installCRDs: true` via Helm values**, rather than the separate `kubectl apply` of the CRD YAML that cert-manager's own docs default to. Keeps the entire install — CRDs included — inside one ArgoCD-managed Application, consistent with "no further kubectl is needed to deploy workloads" (Bootstrap, per `CONTEXT.md`).

**Own `cert-manager` namespace, sync-wave `"0"`.** Same reasoning as ADR 0005: cert-manager is third-party software with its own RBAC surface, so it gets its own namespace rather than sharing one. Wave `"0"` matches `sealed-secrets`' wave, since neither has a same-repo dependency on the other — cert-manager just needs to be healthy before wave `"1"`'s `letsencrypt-issuer` (#46) applies.

**Version pinning.** `targetRevision` SHALL pin an exact chart version (not a floating tag), so ArgoCD's diff/sync is deterministic and a version bump is a reviewable one-line change. Exact version selected during `/opsx:apply`, checked against the current stable release at implementation time.

## Risks / Trade-offs

- **[Risk]** Helm chart rendering at sync time is a new mechanism in this repo (everything else is static YAML) → **Mitigation**: scoped to this one Application; if it causes ArgoCD friction, the fallback is reverting to a vendored manifest, which is a mechanical (not architectural) change.
- **[Risk]** `installCRDs: true` deletes CRDs on Helm uninstall by default in some chart versions, which could cascade-delete any `Certificate`/`ClusterIssuer` resources if the Application were ever pruned → **Mitigation**: `syncPolicy.automated.prune: true` is scoped to this Application only; deleting the `cert-manager` Application is a deliberate, reviewed action, not an automatic side effect of other changes.
- **[Risk]** Webhook readiness lag — cert-manager's admission webhook can take a few seconds after the Deployment reports Ready before it actually accepts `ClusterIssuer`/`Certificate` objects → **Mitigation**: out of scope here since #46 owns the ClusterIssuer, but worth noting in that change's design if sync failures show up on first apply.

## Migration Plan

1. Add `deploy/apps/cert-manager.yaml` (Helm-source Application, sync-wave `"0"`).
2. Commit, merge, let ArgoCD sync.
3. Verify controller/webhook/cainjector Pods are Running in the `cert-manager` namespace and the three core CRDs are registered.
4. No rollback beyond deleting the Application — nothing else in the cluster depends on cert-manager until #46 lands.

## Open Questions

- Exact chart `targetRevision` to pin — resolved at implementation time in `tasks.md` against the current stable release.
