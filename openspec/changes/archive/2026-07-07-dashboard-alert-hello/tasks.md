## 1. Hello dashboard ConfigMap + Application

- [x] 1.1 `deploy/observability-config/grafana-dashboard-hello/configmap.yaml` defines a ConfigMap labeled `grafana_dashboard: "1"` with dashboard JSON under data key `hello.json`
- [x] 1.2 Dashboard JSON includes three panels, all scoped to `job="hello"`: request rate broken out by `http_response_status_code`, p50/p95 latency via `histogram_quantile` over `http_server_request_duration_seconds_bucket`, and a non-2xx rate panel — with no panel broken out by `http_route`
- [x] 1.3 `deploy/observability-config/grafana-dashboard-hello/kustomization.yaml` lists the ConfigMap resource
- [x] 1.4 `deploy/apps/grafana-dashboard-hello.yaml` (new ArgoCD Application, sync-wave `"2"`) sources `deploy/observability-config/grafana-dashboard-hello/` and targets the `observability` namespace

## 2. Grafana sidecar enablement

- [x] 2.1 `deploy/apps/grafana.yaml` Helm values add `sidecar.dashboards.enabled: true` alongside the existing `sidecar.datasources.enabled`
- [x] 2.2 `deploy/apps/grafana.yaml` contains no inline dashboard-provisioning block

## 3. Prometheus alerting rule

- [x] 3.1 `deploy/apps/prometheus.yaml` Helm values add `serverFiles."alerting_rules.yml"` with a rule group evaluating `increase(http_server_request_duration_seconds_count{job="hello",http_response_status_code!~"2.."}[5m]) > 0`, `for: 0m`
- [x] 3.2 `alertmanager.enabled` remains `false` and no `alerting.alertmanagers` target is configured

## 4. Spec/doc updates

- [x] 4.1 `openspec/specs/grafana/spec.md` delta narrows the "no bundled sidecar" scenario to name both the datasource and dashboard sidecars (captured in this change's `specs/grafana/spec.md`)
- [x] 4.2 `docs/adr/0010-bare-prometheus-over-kube-prometheus-stack.md`'s Consequences section corrected to reflect that no Alertmanager is needed
- [x] 4.3 `deploy/CLAUDE.md` documents sizing alert lookback windows to at least 4x the metric's push interval

## 5. Post-deploy verification (requires the live sync — do last)

- [x] 5.1 After ArgoCD syncs, `ssh miniser` + `kubectl -n observability get applications` shows `grafana-dashboard-hello` synced and healthy — root app hadn't picked up the merge commit yet (last reconcile predated it); triggered `kubectl annotate application root argocd.argoproj.io/refresh=hard`, after which `grafana-dashboard-hello` appeared and reported `Synced`/`Healthy`, and `grafana`/`prometheus` both returned to `Healthy` after restarting to pick up the new sidecar/rule config
- [x] 5.2 Grafana's dashboard list (UI or API) shows the hello dashboard with all three panels rendering live data — confirmed via `/api/search?query=hello` (dashboard present) and querying each panel's exact expr through Grafana's datasource-proxy after generating live GET/POST traffic against `https://xdezex.duckdns.org/hello`: request-rate panel returned nonzero `200`/`405` series, latency panel returned a real p95 value, non-2xx panel returned the `405` series
- [x] 5.3 `curl -X POST` against hello's root endpoint produces a 405, and within 5 minutes Prometheus's `/alerts` view shows the rule `firing` — confirmed `405` response, then `GET /api/v1/rules` on the Prometheus pod showed `HelloNon2xxResponses` in state `firing` with the `405` sample as its triggering series
- [x] 5.4 The same alert is visible read-only under Grafana's data-source-managed alerting view — confirmed via `/api/datasources/proxy/uid/.../api/v1/rules` on the Grafana pod, showing the same `firing` rule proxied through the Prometheus datasource (Grafana's own `/api/prometheus/grafana/api/v1/rules`, for Grafana-managed rules, correctly returns empty since this rule is datasource-native, not Grafana-managed)
