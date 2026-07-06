## 1. cert-manager installs as an Infra component via Helm source

- [x] 1.1 Determine the current stable cert-manager chart version to pin as `targetRevision` (v1.20.3, latest non-prerelease as of 2026-07-06)
- [x] 1.2 Add `deploy/apps/cert-manager.yaml`: ArgoCD Application, Helm source `https://charts.jetstack.io` / chart `cert-manager`, destination namespace `cert-manager`, `syncPolicy.automated` with `prune`/`selfHeal`, `syncOptions: [CreateNamespace=true]`, annotated `argocd.argoproj.io/sync-wave: "0"`
- [x] 1.3 Set Helm values `installCRDs: true` on the Application
- [x] 1.4 Lint the new manifest (`yamllint`) per `deploy/CLAUDE.md` conventions

## 2. Controller is healthy and CRDs are registered

- [ ] 2.1 Commit and let ArgoCD sync; confirm the `cert-manager` Application reaches `Synced`/`Healthy`
- [ ] 2.2 Confirm controller, webhook, and cainjector Pods are Running in the `cert-manager` namespace
- [ ] 2.3 Confirm `certificates.cert-manager.io`, `issuers.cert-manager.io`, and `clusterissuers.cert-manager.io` CRDs are registered (`kubectl get crd | grep cert-manager.io`)
