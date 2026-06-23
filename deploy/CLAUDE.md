# Kubernetes / ArgoCD Guidelines

Manifests in `deploy/` are synced by ArgoCD (GitOps). Changes here affect the live cluster on the Raspberry Pi 4B.

## Structure

```
deploy/apps/        # per-app ArgoCD Application manifests
deploy/bootstrap/   # cluster bootstrap (ArgoCD install, root app, default project)
```

## Conventions

- Use kustomization.yaml for grouping; prefer patches over duplicating full manifests
- Lint YAML with `yamllint` before committing
- Never apply manifests directly with `kubectl apply` — let ArgoCD sync
