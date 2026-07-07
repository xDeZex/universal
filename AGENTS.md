# Claude Guidelines

## Project

A personal all-in-one Flutter app (checklist today, gym tracking planned) plus a backend playground: Go services on a Beelink SER5 (k3s + ArgoCD GitOps), built to learn microservices, event-driven architecture, observability, and CI/CD. See README.md for the roadmap and architecture.

See `CONTEXT.md` for the full domain vocabulary.

## General rules

Never `git push` unless explicitly told to.

Before running `/opsx:explore`, `/opsx:propose`, or `/opsx:apply` — or starting any other fresh implementation — create a new branch (`git checkout -b <name>`), then run `git fetch origin && git rebase origin/main` to ensure it is up to date with main. For continuing work on an existing branch, just rebase. Never explore, propose, or apply on `main`.

### Commit and review workflow

OpenSpec apply commits are marked `[temporary]` in their message. These are expected to be squashed before a PR.

Each PR must have exactly one commit and must target `main`. Before creating a PR, confirm with the user that they want to squash, then squash all commits into one: `git reset --soft origin/main`, recommit with the final message. If the branch contains multiple unrelated commits, first fetch and check whether any earlier PRs have already merged into `main` (`git fetch origin && git log origin/main..HEAD`) — the branch may look clean once main is up to date. Only if genuinely unrelated commits remain should you create a separate PR for each by cherry-picking onto a fresh branch from `main`.

When asked to "automerge": fetch origin, check `git log origin/main..HEAD` and open PRs (`gh pr list`) to understand the current state. If the branch contains an OpenSpec change, ensure it has been archived before squashing. Then create a PR for the latest commit and enable automerge (`gh pr merge --auto --rebase`).

To poll a PR's CI status, use `gh pr checks <number> --watch` rather than sleeping in a loop — it polls automatically (default every 10s, `-i` to change) and exits once all checks finish, or immediately on the first failure with `--fail-fast`.

## Architecture

```
app/        # Flutter app — see app/CLAUDE.md
services/   # Go backend services, one dir per service
deploy/     # Kubernetes manifests synced by ArgoCD
```

## Git & Environment

- After cloning, activate shared git hooks: `git config core.hooksPath .githooks`

## Infrastructure Access

- The k3s host (Beelink SER5, LAN-only) is reachable over SSH via the `miniser` alias (`ssh miniser`), configured in `~/.ssh/config` with key-based auth.
- On the host, use the user kubeconfig rather than the root-owned `/etc/rancher/k3s/k3s.yaml`: `kubectl --kubeconfig=/home/oliver/.kube/config ...`, e.g. `ssh miniser "kubectl --kubeconfig=/home/oliver/.kube/config -n services get pods"`.
- The `argocd` CLI isn't installed on the host. To poll an ArgoCD Application's sync/health status without sleeping in a loop, use `kubectl wait --for=jsonpath=...` (blocks and polls until the field matches, then exits):
  ```bash
  ssh miniser "kubectl --kubeconfig=/home/oliver/.kube/config -n argocd wait --for=jsonpath='{.status.sync.status}'=Synced application/<name> --timeout=300s && \
  kubectl --kubeconfig=/home/oliver/.kube/config -n argocd wait --for=jsonpath='{.status.health.status}'=Healthy application/<name> --timeout=300s"
  ```
