## 1. Telemetry bootstrap

- [x] 1.1 `services/hello/go.mod` gains `go.opentelemetry.io/otel`, `go.opentelemetry.io/otel/sdk/metric`, `go.opentelemetry.io/otel/exporters/otlp/otlpmetric/otlpmetrichttp`, `go.opentelemetry.io/contrib/instrumentation/net/http/otelhttp`
- [x] 1.2 `services/hello/internal/telemetry/telemetry.go` exposes `Setup(ctx context.Context, serviceVersion string) (shutdown func(context.Context) error, err error)` that builds a `MeterProvider` with an `otlpmetrichttp`-backed `PeriodicReader`
- [x] 1.3 The resource passed to the `MeterProvider` sets `service.name` from `OTEL_SERVICE_NAME` and `service.version` from the existing `version` package variable
- [x] 1.4 `main()` calls `telemetry.Setup` on startup and defers/handles the returned shutdown func on exit

## 2. Root endpoint is instrumented, health endpoint is not

- [x] 2.1 `newMux()` registers `/` wrapped in `otelhttp.NewHandler(http.HandlerFunc(rootHandler), "root")`
- [x] 2.2 `/healthz` remains registered exactly as today, with no `otelhttp` wrapping
- [x] 2.3 Existing `handler_test.go`/`server_test.go` tests still pass unchanged against the wrapped mux

## 3. Metrics are actually recorded

- [x] 3.1 A test using `metric.NewManualReader()` drives a request through the `otelhttp`-wrapped `/` handler and asserts a recorded data point tagged with operation `"root"`
- [x] 3.2 A test asserts `POST /` (405) still records a metric reflecting the 405 status
- [x] 3.3 A test asserts no metric is recorded for `/healthz` (GET or POST)

## 4. Deployment wiring

- [x] 4.1 `deploy/services/hello/otel-config.yaml` (ConfigMap) sets `OTEL_EXPORTER_OTLP_ENDPOINT=http://otel-collector-opentelemetry-collector.observability.svc.cluster.local:4318` and `OTEL_SERVICE_NAME=hello`
- [x] 4.2 `deploy/services/hello/deployment.yaml` adds `envFrom: configMapRef` referencing the new ConfigMap
- [x] 4.3 `deploy/services/hello/kustomization.yaml` lists the new ConfigMap resource

## 5. Post-deploy verification (requires the live sync — do last)

- [x] 5.1 After ArgoCD syncs, `ssh miniser` + `kubectl -n services get pods` shows the `hello` pod `Running` and `Ready` (unaffected by the new env/config)
- [x] 5.2 `kubectl -n observability logs` on the collector pod shows OTLP metric payloads from `service.name=hello` via the `debug` exporter within one export interval
