## 1. letsencrypt-prod ClusterIssuer deploys as its own Infra config Application

- [x] 1.1 Add `deploy/apps/letsencrypt-issuer.yaml`: ArgoCD Application, git source (this repo, `main`, path `deploy/infra-config/letsencrypt-issuer`), destination namespace `cert-manager`, `syncPolicy.automated` with `prune`/`selfHeal`, `syncOptions: [CreateNamespace=true]`, annotated `argocd.argoproj.io/sync-wave: "1"`
- [x] 1.2 Add `deploy/infra-config/letsencrypt-issuer/kustomization.yaml` with `resources: [clusterissuer.yaml]` (no `namespace:` field — `ClusterIssuer` is cluster-scoped and kustomize can't tell that for CRDs)
- [x] 1.3 Add `deploy/infra-config/letsencrypt-issuer/clusterissuer.yaml`: `ClusterIssuer` named `letsencrypt-prod`, ACME server `https://acme-v02.api.letsencrypt.org/directory`, `email: ollibolli.lillberg@gmail.com`, `privateKeySecretRef` name in the `cert-manager` namespace, HTTP-01 solver with `ingress.ingressClassName: traefik`
- [x] 1.4 Lint the new manifests (`yamllint`) per `deploy/CLAUDE.md` conventions

## 2. Issuer reports Ready after HTTP-01 registration

- [x] 2.1 Commit and let ArgoCD sync; confirm the `letsencrypt-issuer` Application reaches `Synced`/`Healthy`
- [x] 2.2 Confirm the `letsencrypt-prod` `ClusterIssuer` reports `Ready: True` (`ssh miniser` → `sudo kubectl describe clusterissuer letsencrypt-prod`)
- [x] 2.3 Confirm the ACME account private key `Secret` exists in the `cert-manager` namespace, referenced by the `ClusterIssuer`'s `privateKeySecretRef`
