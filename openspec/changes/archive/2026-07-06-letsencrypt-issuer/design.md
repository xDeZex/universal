## Context

cert-manager (#45) is installed and healthy in the cluster. This is the second link in the TLS chain for #13: cert-manager install → `letsencrypt-prod` `ClusterIssuer` (this change) → the `tls:` block on hello's ingress (later). Per `CONTEXT.md`, this change is Infra config, not an Infra component: it authors a manifest (`ClusterIssuer`) that configures an already-installed third-party controller (cert-manager), installing no new software. Infra config lives under `deploy/infra-config/`, a sibling of `deploy/infra/`, each still with its own Application under `deploy/apps/`.

## Goals / Non-Goals

**Goals:**
- `letsencrypt-prod` `ClusterIssuer` created, synced by ArgoCD, reporting `Ready: True`
- Positioned (namespace, sync-wave) so it reliably applies only after cert-manager's CRDs/webhook are up
- HTTP-01 validation routed through the cluster's actual ingress controller (Traefik, confirmed as the default `IngressClass`)

**Non-Goals:**
- Any `Certificate` resource or hello's ingress `tls:` block — that's the next step in #13, once this issuer exists
- The global Traefik HTTP→HTTPS redirect — unrelated, tracked separately
- A staging/dry-run `ClusterIssuer` — going straight to the production ACME server (see Decisions)

## Decisions

**Infra config under `deploy/infra-config/letsencrypt-issuer/`, not `deploy/infra/`.** The existing precedent (`sealed-secrets`, `duckdns-updater`) lives under `deploy/infra/<name>/`, but those install third-party software. This change only authors a `ClusterIssuer` YAML against an already-installed controller, which `CONTEXT.md` explicitly names as the "Infra config" category with its own sibling directory. Getting this placement wrong was the main risk of just copying the `duckdns-updater` layout blind.

**Own ArgoCD Application, sync-wave `"1"`.** Same reasoning as `duckdns-updater`: a separate git-sourced Application (not folded into `deploy/apps/cert-manager.yaml`) so the `ClusterIssuer`'s lifecycle isn't coupled to the Helm release, and wave `"1"` guarantees cert-manager's webhook (wave `"0"`) is already accepting `ClusterIssuer` objects.
_Alternative considered_: bump cert-manager's own Application to also manage the `ClusterIssuer` via a post-sync hook. Rejected — mixes a third-party Helm release with project-authored config in one Application, and the cert-manager spec's own "Contract" scenario already assumes a separate downstream Application.

**Production ACME server directly, no staging issuer.** Let's Encrypt's staging environment exists to avoid rate limits during iteration, but this is a single-domain (`xdezex.duckdns.org`), low-churn setup and the manifest itself (server URL, email, solver) is simple enough to get right in one pass. A failed prod order just delays readiness, it doesn't lock anything out.
_Alternative considered_: add a `letsencrypt-staging` `ClusterIssuer` first, verify Ready, then add prod. Rejected as unnecessary ceremony for this scope — revisit if a prod order ever gets rate-limited.

**HTTP-01 via `ingressClassName: traefik`**, not the older `class` field. Confirmed via `ssh miniser` (`kubectl get ingressclass`) that `traefik` is the cluster's default `IngressClass`. Using `ingressClassName` (cert-manager v1.2+) matches how the rest of the cluster already omits an explicit class and relies on the same controller.

**Account private key `Secret` in the `cert-manager` namespace, with no `namespace:` field in the kustomization.** cert-manager's "cluster resource namespace" (where it stores the ACME account key `Secret`) defaults to the namespace the controller itself runs in, per `deploy/apps/cert-manager.yaml` — this is controlled by cert-manager's own config, not by anything in this Application. `ClusterIssuer` itself is cluster-scoped, and kustomize's namespace transformer doesn't know that for CRDs (it only recognizes a hardcoded list of built-in cluster-scoped kinds), so setting `namespace: cert-manager` in `kustomization.yaml` would incorrectly stamp `metadata.namespace` onto the `ClusterIssuer`, which the API server rejects on cluster-scoped resources. The `kustomization.yaml` therefore has no `namespace:` field at all — the only thing it lists is the cluster-scoped `ClusterIssuer`. The Application's `spec.destination.namespace: cert-manager` is kept for consistency with the other Applications and because ArgoCD's own sync engine is scope-aware via live API discovery (unlike kustomize's static transform), so it's harmless there.

## Risks / Trade-offs

- **[Risk]** Webhook readiness lag flagged in the cert-manager design as a risk for this change: the admission webhook can take a few seconds after its Deployment reports Ready before it accepts `ClusterIssuer` objects → **Mitigation**: ArgoCD's `selfHeal: true` retries the sync automatically; no manual intervention expected, but worth checking sync history if the first sync fails.
- **[Risk]** HTTP-01 validation requires port 80 forwarded from the router to Traefik — this is outside the repo and cluster entirely → **Mitigation**: previously flagged as a precondition of #13; if the issuer doesn't reach `Ready`, this is the first thing to check via `ssh miniser`, not the manifest.
- **[Risk]** Going straight to the production ACME server means a manifest mistake could in theory contribute to Let's Encrypt's rate limits → **Mitigation**: single domain, manual single apply, low iteration count; acceptable for this scope (see Decisions).

## Migration Plan

1. Add `deploy/apps/letsencrypt-issuer.yaml` (git-sourced Application, sync-wave `"1"`, path `deploy/infra-config/letsencrypt-issuer/`).
2. Add `deploy/infra-config/letsencrypt-issuer/kustomization.yaml` (namespace `cert-manager`) and `clusterissuer.yaml` (the `letsencrypt-prod` `ClusterIssuer`, ACME prod server, email, HTTP-01/traefik solver).
3. Commit, merge, let ArgoCD sync.
4. Verify via `ssh miniser` (`sudo kubectl get clusterissuer letsencrypt-prod -o wide` / `describe`) that it reports `Ready: True`.
5. Rollback: delete the `letsencrypt-issuer` Application. Nothing else in the cluster references `letsencrypt-prod` yet, so this is a clean revert.

## Open Questions

None outstanding — naming, namespace, ingress class, and ACME email were all confirmed during exploration before this proposal was written.
