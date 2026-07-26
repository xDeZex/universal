# Kubernetes / ArgoCD Guidelines

Manifests in `deploy/` are synced by ArgoCD (GitOps). Changes here affect the live cluster on the Beelink SER5.

## Structure

```
deploy/apps/        # per-app ArgoCD Application manifests
deploy/bootstrap/   # cluster bootstrap (ArgoCD install, root app, default project)
```

## Conventions

- Lint YAML with `yamllint` before committing
- Never apply manifests directly with `kubectl apply` — let ArgoCD sync

## Standards

See `docs/agents/deploy/CODING_STANDARDS.md`.
