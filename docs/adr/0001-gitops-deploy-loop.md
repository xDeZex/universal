# GitOps deploy loop: CI commits Kustomize tag bumps, ArgoCD syncs

The backend runs on a single Beelink SER5 under k3s, and we want every deploy to be auditable and revertable from git alone. We decided: GitHub Actions builds linux/amd64 images tagged with the git SHA, pushes them to GHCR, then commits the new tag into `deploy/`'s `kustomization.yaml` on `main` (the "Deploy commit"); ArgoCD (core install) auto-syncs with self-heal and prune, so a file change in git is the only mechanism that alters the cluster. CI holds no cluster credentials.

Config lives in this same monorepo rather than a separate config repo (solo project — path filters give the same isolation without two-repo overhead).

## Consequences

- `main` is protected via a GitHub ruleset (tests gate PRs). Deploy commits push directly to `main` using a fine-grained PAT (`contents: write` only, stored as a repo secret) belonging to the repo owner's own account, which already holds the ruleset's admin bypass (`bypass_actors: RepositoryRole, bypass_mode: always`) — no separate bot bypass actor was added. An auto-merged PR per deploy was rejected: it would queue a one-line `deploy/` change behind minutes of unrelated Flutter CI.
- `ci.yml`'s `filter` job (via `dorny/paths-filter`) gates `test-hello`, `build-hello`/`push-hello`/`deploy-hello`, and `lint-deploy` on PRs, so a Flutter-only PR doesn't run them. On pushes to `main`, `test-hello` and `lint-deploy` intentionally always run regardless of path (a cheap safety net); only `build-hello`/`push-hello`/`deploy-hello` stay gated even on push, since building/deploying an image is not cheap or idempotent. The Flutter side (`test`, `build-universal`/`release-universal`) is now also path-filtered on `app/**` (see the `app-build-release` change): a Deploy commit or any push touching only `services/**`/`deploy/**` no longer triggers a Flutter test run or a new GitHub Release.

## Considered options

- **ArgoCD Image Updater** — watches GHCR and bumps tags in-cluster. Rejected: its git write-back mode commits a generated `.argocd-source-<app>.yaml` overlay rather than patching `kustomization.yaml` directly, splitting the source of truth for the running image tag. For a single-service monorepo the branch-bypass rule is a one-time setup cost, and CI-commits keeps `kustomization.yaml` as the sole authoritative record. Image Updater's value scales with the number of images tracked; it's not worth the extra in-cluster component here.
- **`:latest` + rollout restart** — rejected: no audit trail, no `git revert` rollback, Kubernetes can't observe that an image behind a mutable tag changed.
- **Separate config repo** (Argo docs' default recommendation) — rejected for a solo monorepo; the isolation it buys is already achieved with workflow path filters.
