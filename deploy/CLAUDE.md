# Kubernetes / ArgoCD Guidelines

Manifests in `deploy/` are synced by ArgoCD (GitOps). Changes here affect the live cluster on the Beelink SER5.

## Structure

```
deploy/apps/        # per-app ArgoCD Application manifests
deploy/bootstrap/   # cluster bootstrap (ArgoCD install, root app, default project)
```

## Conventions

- Use kustomization.yaml for grouping; prefer patches over duplicating full manifests
- Lint YAML with `yamllint` before committing
- Never apply manifests directly with `kubectl apply` — let ArgoCD sync
- Size Prometheus alert `rate()`/`increase()` lookback windows to at least 4x the metric's actual delivery interval, not scrape-interval habits. Services here push OTel metrics on their SDK's own export interval (default 60s, e.g. `hello`'s `telemetry.go`) rather than being scraped, so a new data point only lands roughly that often. A window sized for a fast scrape interval (e.g. `[1m]`) can straddle a gap between pushes and evaluate as no data instead of firing. Use `for:` to suppress flapping on noisy signals, not to compensate for a too-narrow window.
