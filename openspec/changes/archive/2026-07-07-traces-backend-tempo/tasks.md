## 1. Tempo deployment

- [x] 1.1 `deploy/apps/tempo.yaml` (new ArgoCD Application) sources the upstream `grafana/tempo` (monolithic) Helm chart directly, targeting the `observability` namespace
- [x] 1.2 Helm values configure `local` filesystem storage for trace blocks — no `s3`/`gcs`/`azure` backend, no bundled minio
- [x] 1.3 Helm values configure persistent storage with `storageClassName: observability-retain`, size `1Gi`
- [x] 1.4 Helm values set `compactor.compaction.block_retention` to `72h`
- [x] 1.5 Helm values set explicit `resources.requests`/`resources.limits` for CPU and memory
- [x] 1.6 Tempo's OTLP receiver (grpc `4317` + http `4318`) is enabled on its in-cluster Service

## 2. otel-collector traces pipeline

- [x] 2.1 `deploy/apps/otel-collector.yaml`'s `traces` pipeline exporters change to `[otlphttp]` targeting Tempo's Service, `debug` dropped
- [x] 2.2 The `otlphttp` exporter's endpoint matches Tempo's in-cluster Service DNS name and OTLP http port
- [x] 2.3 The `logs` pipeline is confirmed unchanged (`otlp` receiver → `debug` exporter only)

## 3. Grafana datasource for Tempo

- [x] 3.1 `deploy/observability-config/grafana-datasource/` gains a Tempo datasource ConfigMap, labeled for sidecar discovery, alongside the existing Prometheus/Loki datasource ConfigMaps
- [x] 3.2 The Tempo datasource's `url` targets Tempo's in-cluster Service DNS name
- [x] 3.3 The Tempo datasource ConfigMap contains no `tracesToLogsV2`/`tracesToMetrics` correlation fields
- [x] 3.4 `deploy/apps/grafana.yaml`'s Helm values contain no inline Tempo `datasources` provisioning block

## 4. hello tracer SDK

- [x] 4.1 `services/hello/internal/telemetry` gains a `SetupTraces(ctx, serviceVersion)` function building a `TracerProvider` backed by `otlptracehttp` + `BatchSpanProcessor`, using the same `newResource` helper `Setup` already uses
- [x] 4.2 The `TracerProvider` is registered globally via `otel.SetTracerProvider`
- [x] 4.3 `main.go` calls `SetupTraces` alongside `Setup` and defers both shutdown funcs independently
- [x] 4.4 The telemetry package gains tests covering trace provider setup and resource attributes, mirroring the existing `Setup` tests
- [x] 4.5 A `GET /` request produces a span tagged operation `"root"` once the `TracerProvider` is registered, verified against a local/in-memory exporter in a test

## 5. Document the decision

- [x] 5.1 `docs/adr/0012-tempo-over-jaeger-for-traces.md` records choosing Tempo (monolithic chart) over Jaeger
- [x] 5.2 `CONTEXT.md`'s "Observability component" entry names Tempo explicitly, replacing the "later a traces backend" placeholder

## 6. Post-deploy verification (requires the live sync — do last)

- [x] 6.1 After ArgoCD syncs, `ssh miniser` + `kubectl -n observability get pods` shows the Tempo pod `Running`/`Ready` with its PVC `Bound`
- [x] 6.2 `kubectl -n observability logs` on the otel-collector pod shows no errors exporting to Tempo
- [x] 6.3 In Grafana, the Tempo datasource is present and its connection test succeeds
- [x] 6.4 A `GET` request to `hello`'s `/` endpoint, followed by a Grafana Explore (Tempo datasource) search, returns a trace for that request
- [x] 6.5 The returned trace's span is tagged operation `"root"` and carries `service.name=hello`, `service.version` matching hello's deployed image version
