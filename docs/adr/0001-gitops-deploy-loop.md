# GitOps deploy loop: CI commits Kustomize tag bumps, ArgoCD syncs

The backend runs on a single Raspberry Pi 4B (4GB) under k3s, and we want every deploy to be auditable and revertable from git alone. We decided: GitHub Actions builds linux/arm64 images tagged with the git SHA, pushes them to GHCR, then commits the new tag into `deploy/`'s `kustomization.yaml` on `main` (the "Deploy commit"); ArgoCD (core install) auto-syncs with self-heal and prune, so a file change in git is the only mechanism that alters the cluster. CI holds no cluster credentials.

Config lives in this same monorepo rather than a separate config repo (solo project — path filters give the same isolation without two-repo overhead).

## Consequences

- `main` will be protected via a GitHub ruleset (tests gate PRs), with a bypass for the deploy workflow's identity — Deploy commits push directly to `main` without re-running the Flutter gate. Not yet configured; this is Phase 0 work. An auto-merged PR per deploy was rejected: it would queue a one-line `deploy/` change behind minutes of unrelated Flutter CI.
- Both CI workflows will need path filters (Flutter: `lib/`, `test/`, `android/`, `pubspec.*`; backend: `services/`, `deploy/`) so Deploy commits don't trigger APK releases and backend pushes don't run Flutter tests. The current `ci.yml` has none yet, and the backend workflow doesn't exist — also Phase 0 work.

## Considered options

- **ArgoCD Image Updater** — watches GHCR and bumps tags in-cluster. Rejected: its git write-back mode commits a generated `.argocd-source-<app>.yaml` overlay rather than patching `kustomization.yaml` directly, splitting the source of truth for the running image tag. For a single-service monorepo the branch-bypass rule is a one-time setup cost, and CI-commits keeps `kustomization.yaml` as the sole authoritative record. Image Updater's value scales with the number of images tracked; it's not worth the extra in-cluster component here.
- **`:latest` + rollout restart** — rejected: no audit trail, no `git revert` rollback, Kubernetes can't observe that an image behind a mutable tag changed.
- **Separate config repo** (Argo docs' default recommendation) — rejected for a solo monorepo; the isolation it buys is already achieved with workflow path filters.
