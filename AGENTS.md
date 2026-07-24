# Claude Guidelines

## Project

A personal all-in-one Flutter app (checklist today, gym tracking planned) plus a backend playground: Go services on a Beelink SER5 (k3s + ArgoCD GitOps), built to learn microservices, event-driven architecture, observability, and CI/CD. See README.md for the roadmap and architecture.

See `CONTEXT.md` for the full domain vocabulary.

## General rules

Never `git push` unless explicitly told to.

OpenSpec's `proposal → specs → design → tasks → apply` pipeline is for `services/`/`deploy/` work only. App work (`universal/`) uses `wayfinder`/`to-tickets` → `implement-ticket` instead — see `universal/CLAUDE.md`.

Before starting any fresh implementation — `/opsx:explore`/`/opsx:propose`/`/opsx:apply`, `implement-ticket`, or anything else — create a new branch (`git checkout -b <name>`), then run `git fetch origin && git rebase origin/main` to ensure it is up to date with main. For continuing work on an existing branch, just rebase. Never explore, propose, apply, or implement on `main`.


### Background agents

Background jobs in this repo must not auto-ship: after making code changes, stop once the work is committed locally in the worktree — do not `git push` and do not open a draft PR, even though the harness default for background jobs is to commit, push, and open a draft PR automatically. This overrides that default here. Leave the branch and worktree in place and report where the work is; the user will push and open the PR themselves. Otherwise, follow the existing instructions and conventions already documented in this file (research, branching, commit/squash, and review workflow above).

### Research

Investigate questions against primary sources — prefer official docs, specs, and first-party APIs over source code — don't use any secondary write-ups of them. Follow every claim back to the source that owns it.

### Commit and review workflow

Commits made during implementation are marked `[temporary]` in their message. These are expected to be squashed before a PR.

Each PR must have exactly one commit and must target `main`. Before creating a PR, squash all temporary commits into one: `git reset --soft origin/main`, recommit with the final message. If the branch contains multiple unrelated commits, first fetch and check whether any earlier PRs have already merged into `main` (`git fetch origin && git log origin/main..HEAD`) — the branch may look clean once main is up to date. Only if genuinely unrelated commits remain should you create a separate PR for each by cherry-picking onto a fresh branch from `main`.

When asked to "automerge": fetch origin, check `git log origin/main..HEAD` and open PRs (`gh pr list`) to understand the current state. If the branch contains an OpenSpec change, ensure it has been archived before squashing. Then create a PR for the latest commit and enable automerge (`gh pr merge --auto --rebase`).

To poll a PR's CI status, use `gh pr checks <number> --watch` rather than sleeping in a loop — it polls automatically (default every 10s, `-i` to change) and exits once all checks finish, or immediately on the first failure with `--fail-fast`.

## Architecture

```
universal/  # Flutter app — see universal/CLAUDE.md
services/   # Go backend services, one dir per service
deploy/     # Kubernetes manifests synced by ArgoCD
```

## Git & Environment

- After cloning, activate shared git hooks: `git config core.hooksPath .githooks`
- Never run the git hooks manually (e.g. invoking `.githooks/pre-commit` directly). Just `git commit` and let them run automatically.

## Infrastructure Access

- The k3s host (Beelink SER5, LAN-only) is reachable over SSH via the `miniser` alias (`ssh miniser`), configured in `~/.ssh/config` with key-based auth.
- On the host, use the user kubeconfig rather than the root-owned `/etc/rancher/k3s/k3s.yaml`: `kubectl --kubeconfig=/home/oliver/.kube/config ...`, e.g. `ssh miniser "kubectl --kubeconfig=/home/oliver/.kube/config -n services get pods"`.
- The `argocd` CLI isn't installed on the host. To poll an ArgoCD Application's sync/health status without sleeping in a loop, use `kubectl wait --for=jsonpath=...` (blocks and polls until the field matches, then exits):
  ```bash
  ssh miniser "kubectl --kubeconfig=/home/oliver/.kube/config -n argocd wait --for=jsonpath='{.status.sync.status}'=Synced application/<name> --timeout=300s && \
  kubectl --kubeconfig=/home/oliver/.kube/config -n argocd wait --for=jsonpath='{.status.health.status}'=Healthy application/<name> --timeout=300s"
  ```
