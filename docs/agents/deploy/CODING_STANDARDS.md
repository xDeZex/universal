# Coding Standards — deploy/ (Kubernetes / ArgoCD)

- Use kustomization.yaml for grouping; prefer patches over duplicating full manifests
- Size Prometheus alert `rate()`/`increase()` lookback windows to at least 4x the metric's actual delivery interval, not scrape-interval habits. Services here push OTel metrics on their SDK's own export interval (default 60s, e.g. `hello`'s `telemetry.go`) rather than being scraped, so a new data point only lands roughly that often. A window sized for a fast scrape interval (e.g. `[1m]`) can straddle a gap between pushes and evaluate as no data instead of firing. Use `for:` to suppress flapping on noisy signals, not to compensate for a too-narrow window.
