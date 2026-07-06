## 1. Collector is deployed as its own Application

- [x] 1.1 `deploy/apps/otel-collector.yaml` is a Helm-sourced ArgoCD Application (`chart: opentelemetry-collector`, `repoURL: https://open-telemetry.github.io/opentelemetry-helm-charts`, destination namespace `observability`, `CreateNamespace=true`, `sync-wave: "0"`), synced automatically with `prune: true` / `selfHeal: true`
- [x] 1.2 `helm.values` sets `mode: deployment`
- [x] 1.3 `helm.values` sets `image.repository` to the Contrib image (`otel/opentelemetry-collector-contrib`)
- [x] 1.4 `helm.values` sets non-empty `resources.requests` and `resources.limits` (CPU + memory)

## 2. OTLP receiver accepts grpc and http, exports only to debug

- [x] 2.1 `helm.values` `config.receivers` defines only `otlp`, with both `grpc` (`4317`) and `http` (`4318`) protocols enabled
- [x] 2.2 `helm.values` `config.exporters` defines only `debug`
- [x] 2.3 `helm.values` `config.service.pipelines` wires every signal type the receiver carries (traces/metrics/logs) to `receivers: [otlp]`, `exporters: [debug]`

## 3. Post-deploy verification (requires the live sync — do last)

- [x] 3.1 After ArgoCD syncs, `ssh miniser` + `kubectl -n observability get pods` shows the collector pod `Running` and `Ready`
- [x] 3.2 A test OTLP payload sent to the collector (grpc `:4317` or http `:4318`, port-forwarded or from a throwaway in-cluster pod) appears in `kubectl -n observability logs` via the `debug` exporter
- [x] 3.3 `kubectl -n observability top pod` shows actual usage within the requests/limits set in 1.4 (2m CPU / 29Mi memory observed, well within the 100m/128Mi request and 500m/256Mi limit — no adjustment needed)
