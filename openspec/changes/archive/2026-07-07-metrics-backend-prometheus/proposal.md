## Why

hello's metrics reach the otel-collector today, but the collector only logs them via its `debug` exporter (#61/#63) — nothing persists or can be queried. #62 wires the collector's metrics pipeline to a real backend so hello's metrics are queryable, unblocking Grafana (#64) and the first dashboard/alert (#65).

## What Changes

- Deploy Prometheus as a new Observability component: the bare `prometheus-community/prometheus` chart (server only, no Operator, no bundled Alertmanager/node-exporter/kube-state-metrics/Grafana — see ADR-0010), via its own ArgoCD Application under `deploy/apps/`, in the shared `observability` namespace, with a PVC for its TSDB and 7-day retention
- Add a new `observability-retain` StorageClass — same `rancher.io/local-path` provisioner as the cluster default, `reclaimPolicy: Retain` instead of `Delete` — as Observability config under `deploy/observability-config/storage/`, with its own ArgoCD Application, so Prometheus's TSDB survives an accidental Application deletion. This is the first PVC in the repo and the first Observability config item.
- Swap the otel-collector's **metrics** pipeline exporter from `debug` to `prometheusremotewrite`, pointed at Prometheus's remote-write endpoint. Traces and logs pipelines are unchanged (still `debug`-only, pending #66/#67).
- **BREAKING** (spec-level only, not runtime): reframe the otel-collector's "debug exporter only" requirement to be scoped per signal type — metrics now has a real backend, traces/logs remain debug-only — rather than a blanket rule with a bolted-on exception.

## Capabilities

### New Capabilities
- `prometheus`: Prometheus deployed as an Observability component — chart source, values, namespace, PVC-backed persistence, retention window
- `observability-storage`: the `observability-retain` StorageClass — provisioner, reclaim policy, scope, and its ArgoCD Application wiring

### Modified Capabilities
- `otel-collector`: the "debug exporter only" requirement is replaced with a per-signal-type requirement — metrics pipeline exports to Prometheus via `prometheusremotewrite`, traces/logs pipelines remain debug-only
- `hello-telemetry`: the "metrics reach the collector" scenario no longer asserts the collector's `debug` exporter logs the payload (now false — see `otel-collector` above), and instead defers to the collector's own pipeline configuration

## Impact

- `deploy/apps/prometheus.yaml` (new): ArgoCD Application, Helm-sourced `prometheus-community/prometheus`, PVC via `observability-retain` StorageClass, 7d retention
- `deploy/apps/observability-storage.yaml` (new): ArgoCD Application for the StorageClass manifest
- `deploy/observability-config/storage/` (new): `storageclass.yaml`, `kustomization.yaml`
- `deploy/apps/otel-collector.yaml` (modified): metrics pipeline's `exporters` changes from `[debug]` to `[prometheusremotewrite]`; new `prometheusremotewrite` exporter config pointed at Prometheus
- `openspec/specs/otel-collector/spec.md` (delta): "Debug exporter only, no backend wired" requirement reframed per signal type
- `openspec/specs/hello-telemetry/spec.md` (delta): "Metrics are pushed via OTLP..." scenario's THEN clause updated — no longer hardcodes `debug` as the collector-side outcome
- `docs/adr/0010-bare-prometheus-over-kube-prometheus-stack.md`: already recorded (bare chart vs `kube-prometheus-stack`), referenced here for context
