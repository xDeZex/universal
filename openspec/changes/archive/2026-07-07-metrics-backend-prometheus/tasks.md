## 1. observability-retain StorageClass

- [x] 1.1 `deploy/observability-config/storage/storageclass.yaml` defines `observability-retain` using provisioner `rancher.io/local-path` and `reclaimPolicy: Retain`
- [x] 1.2 The manifest does not set the `storageclass.kubernetes.io/is-default-class` annotation to `"true"`
- [x] 1.3 `deploy/observability-config/storage/kustomization.yaml` lists the StorageClass resource
- [x] 1.4 `deploy/apps/observability-storage.yaml` (new ArgoCD Application, sync-wave `"0"`) sources `deploy/observability-config/storage/` and targets the `observability` namespace

## 2. Prometheus deployment

- [x] 2.1 `deploy/apps/prometheus.yaml` (new ArgoCD Application, sync-wave `"1"`) sources the upstream `prometheus-community/prometheus` Helm chart directly, targeting the `observability` namespace
- [x] 2.2 Helm values enable only the server component — no Alertmanager, node-exporter, kube-state-metrics, or bundled Grafana
- [x] 2.3 Helm values configure persistent storage with `storageClassName: observability-retain` and a modest declared size
- [x] 2.4 Helm values set retention to `7d`
- [x] 2.5 Helm values set explicit `resources.requests`/`resources.limits` for CPU and memory

## 3. otel-collector metrics pipeline wiring

- [x] 3.1 `deploy/apps/otel-collector.yaml` gains a `prometheusremotewrite` exporter configured with Prometheus's in-cluster Service remote-write endpoint
- [x] 3.2 The metrics pipeline's `exporters` list changes from `[debug]` to `[prometheusremotewrite]`
- [x] 3.3 The traces and logs pipelines are left unchanged (`exporters: [debug]`)

## 4. Post-deploy verification (requires the live sync — do last)

- [x] 4.1 After ArgoCD syncs, `ssh miniser` + `kubectl -n observability get storageclass observability-retain` shows the class present with `RECLAIMPOLICY Retain`
- [x] 4.2 `kubectl -n observability get pods` shows the Prometheus pod `Running` and `Ready`, with its PVC `Bound`
- [x] 4.3 `kubectl -n observability logs` on the collector pod shows no errors from the `prometheusremotewrite` exporter
- [x] 4.4 Querying Prometheus's API (e.g. `up` or a `hello`-tagged metric) returns a data point with `service.name="hello"`, confirming the pipeline end to end
