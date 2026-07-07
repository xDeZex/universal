## Why

hello's metrics are queryable in Prometheus (#62) and Grafana can already query that backend (#64), but there's still no dashboard to view them and no alert proving the pipeline can actually notice a bad condition, not just store numbers. #65 closes the observability epic's (#14) first full loop: a human can look at a dashboard and see hello's live behavior, and a deliberately-triggered bad condition surfaces as a firing alert.

## What Changes

- Add a Grafana dashboard for hello — request rate (by status code), p50/p95 latency, and a non-2xx rate panel — provisioned via a ConfigMap, discovered by Grafana's dashboard-sidecar mechanism, mirroring the existing datasource-sidecar ConfigMap pattern (`grafana-datasource`)
- Enable `sidecar.dashboards.enabled` on the `grafana` Application's Helm values, alongside the existing datasource sidecar
- Add a native Prometheus alerting rule (no Alertmanager) that fires when hello's non-2xx response rate is nonzero, using a 5-minute `increase()` window sized against hello's ~60s OTel push interval rather than scrape-interval habits, manually triggerable via a stray non-GET request to hello's root endpoint
- **BREAKING** (spec-level only, not runtime): the `grafana` spec's "no bundled sidecar beyond datasource" scenario is narrowed to name both the datasource and dashboard sidecars as the allowed set, rather than forbidding all but one

## Capabilities

### New Capabilities
- `grafana-dashboard-hello`: the hello dashboard — ConfigMap-provisioned, sidecar-discovered, its own ArgoCD Application independent of `grafana`'s lifecycle, mirroring `grafana-datasource`'s shape

### Modified Capabilities
- `grafana`: the "no bundled sidecar beyond datasource" scenario now permits the dashboard-provisioning sidecar too
- `prometheus`: adds a native alerting rule group (`serverFiles."alerting_rules.yml"`) for hello's non-2xx response rate; no Alertmanager is introduced

## Impact

- `deploy/apps/grafana.yaml` (modified): add `sidecar.dashboards.enabled: true`
- `deploy/observability-config/grafana-dashboard-hello/` (new): `configmap.yaml` (dashboard JSON, labeled `grafana_dashboard: "1"`), `kustomization.yaml`
- `deploy/apps/grafana-dashboard-hello.yaml` (new): ArgoCD Application for the ConfigMap, sync-wave `"2"` (matching `grafana`/`grafana-datasource`), mirroring `deploy/apps/grafana-datasource.yaml`
- `deploy/apps/prometheus.yaml` (modified): add `serverFiles."alerting_rules.yml"` with the non-2xx-rate rule group
- `openspec/specs/grafana/spec.md` (delta): narrow the sidecar-restriction scenario
- `docs/adr/0010-bare-prometheus-over-kube-prometheus-stack.md`: consequence correction (already staged in the working tree from prior discussion)
- `deploy/CLAUDE.md`: alert-window-sizing convention note (already staged in the working tree from prior discussion)
