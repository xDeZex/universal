## 1. Loki deployment

- [x] 1.1 `deploy/apps/loki.yaml` (new ArgoCD Application) sources the upstream `grafana/loki` Helm chart directly, targeting the `observability` namespace
- [x] 1.2 Helm values set `deploymentMode`/chart equivalent to `SingleBinary`
- [x] 1.3 Helm values configure `filesystem` storage for chunks and index — no `s3`/`gcs`/`azure` backend, no bundled minio
- [x] 1.4 Helm values configure persistent storage with `storageClassName: observability-retain`, size `5Gi`
- [x] 1.5 Helm values set the compactor's retention period to `72h`
- [x] 1.6 Helm values set explicit `resources.requests`/`resources.limits` for CPU and memory

## 2. Alloy deployment

- [x] 2.1 `deploy/apps/alloy.yaml` (new ArgoCD Application) sources the upstream `grafana/alloy` Helm chart directly, targeting the `observability` namespace
- [x] 2.2 Helm values set the controller type to `daemonset`
- [x] 2.3 Alloy's config discovers pods cluster-wide via the Kubernetes API, with no namespace allowlist/denylist
- [x] 2.4 Alloy's config mounts the node's `/var/log/pods` directory read-only (hostPath) and tails discovered pods' container log files
- [x] 2.5 Alloy's config labels each log stream with `namespace`, `pod`, and `container`
- [x] 2.6 Alloy's config writes directly to Loki's in-cluster Service push endpoint (`/loki/api/v1/push`) — not through otel-collector
- [x] 2.7 Helm values set explicit `resources.requests`/`resources.limits` for CPU and memory
- [x] 2.8 `deploy/apps/otel-collector.yaml`'s `logs` pipeline (`otlp` receiver → `debug` exporter) is confirmed unchanged

## 3. Grafana datasource for Loki

- [x] 3.1 `deploy/observability-config/grafana-datasource/` gains a Loki datasource ConfigMap, labeled for sidecar discovery, alongside the existing Prometheus datasource ConfigMap
- [x] 3.2 The Loki datasource's `url` targets Loki's in-cluster Service DNS name
- [x] 3.3 `deploy/apps/grafana.yaml`'s Helm values contain no inline Loki `datasources` provisioning block

## 4. Document the routing decision

- [x] 4.1 `docs/adr/0011-grafana-alloy-for-log-collection.md` records choosing Alloy over extending otel-collector's filelog receiver for logs, revisiting ADR-0009's named trigger, scoped to logs only (otel-collector remains the metrics/traces tool)

## 5. Post-deploy verification (requires the live sync — do last)

- [ ] 5.1 After ArgoCD syncs, `ssh miniser` + `kubectl -n observability get pods` shows the Loki pod `Running`/`Ready` with its PVC `Bound`, and an Alloy pod `Running`/`Ready` on the node
- [ ] 5.2 `kubectl -n observability logs` on the Alloy pod shows no errors pushing to Loki
- [ ] 5.3 In Grafana, the Loki datasource is present and its connection test succeeds
- [ ] 5.4 In Grafana Explore (Loki datasource), a LogQL query for `{namespace="services", pod=~"hello.*"}` returns recent log lines from `hello`
- [ ] 5.5 A LogQL query for `{namespace="argocd"}` (or another non-`services` namespace) also returns log lines, confirming all-namespace scope works end to end
