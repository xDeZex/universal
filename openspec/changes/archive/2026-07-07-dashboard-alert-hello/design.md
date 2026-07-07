## Context

hello already pushes metrics through otel-collector into Prometheus (#62), and Grafana already queries that backend (#64). Nothing yet visualizes those metrics or proves the pipeline can raise an alert. `docs/adr/0010-bare-prometheus-over-kube-prometheus-stack.md` originally anticipated #65 would need to add Alertmanager as its own component; that turned out unnecessary once the alerting need was scoped to "fires on a manual test condition" rather than "notifies somewhere real" — the ADR's Consequences section has been corrected accordingly as part of this change.

Live label data was checked against the running Prometheus instance before writing this design (`job="hello"`, `http_request_method="GET"`, `http_response_status_code="200"`, `http_route="/"` all confirmed present), so the panel queries and alert expression below aren't guesses.

## Goals / Non-Goals

**Goals:**
- One Grafana dashboard for hello: request rate by status code, p50/p95 latency, non-2xx rate
- One Prometheus alerting rule that transitions to `firing` on a deliberately-triggered non-2xx response
- Both provisioned as code (ConfigMaps + ArgoCD Applications) — Grafana runs with `persistence.enabled: false`, so anything not provisioned this way evaporates on the next pod restart

**Non-Goals:**
- Alertmanager, notification routing, or any delivery mechanism for the alert — out of scope per the corrected ADR-0010; only relevant once a future alert actually needs to notify somewhere
- Dashboards or alerts for any service other than hello — no second service exists yet
- A dedicated Grafana folder for the dashboard — premature until a second service's dashboard exists to organize alongside it
- Changing hello's OTel export interval — the ~60s default cadence is accepted as a constraint the alert/dashboard design works around, not something tuned to make this change easier

## Decisions

- **Alert lives natively in Prometheus; no Alertmanager.** *Alternatives considered*: (a) a dedicated Alertmanager component, as ADR-0010 originally anticipated — rejected as a whole new Observability component for one manual-test alert with no notification target; (b) Grafana-managed unified alerting — rejected only because it adds Grafana-side alerting config to provision for no benefit over the simpler option, given Grafana can already display Prometheus-native rules read-only via its datasource. A bare rule in `serverFiles."alerting_rules.yml"` needs zero new components and satisfies the done-when as written.
- **`increase(http_server_request_duration_seconds_count{job="hello",http_response_status_code!~"2.."}[5m]) > 0`, `for: 0m`.** hello's OTel `PeriodicReader` exports on a 60s interval (default, unset in `telemetry.go`) rather than being scraped, so Prometheus only sees a new hello sample roughly once a minute. Standard Prometheus guidance sizes `rate()`/`increase()` windows to at least 4x the sample interval; `5m` clears that bar comfortably. `for: 0m` because the window itself already provides the necessary smoothing — stacking a pending duration on top would just add delay without adding correctness. This convention is now recorded in `deploy/CLAUDE.md` so the next service's alert doesn't rediscover it the hard way.
- **Dashboard via ConfigMap + Grafana sidecar, mirroring `grafana-datasource`'s exact shape**: own ArgoCD Application (`grafana-dashboard-hello.yaml`), sync-wave `"2"` alongside `grafana`/`grafana-datasource`, no explicit ordering between them since the sidecar tolerates either syncing first. Chosen over hand-building the dashboard in Grafana's UI, which would not survive a pod restart and would break "if it's not in git, it's not deployed."
- **The dashboard's non-2xx panel intentionally reuses the alerting rule's exact expression.** So the condition that would page (eventually) is always visibly plotted on the dashboard itself, not hidden away in Prometheus's rule config where only someone who goes looking would find it.
- **No panel breaks out by `http_route`.** Only one route (`/`) is instrumented today; `/healthz` is confirmed to emit no metrics. Adding a route dimension now would be designing for a service shape that doesn't exist yet.

## Risks / Trade-offs

- **[Risk]** Widening the `grafana` spec's "no bundled sidecar" scenario weakens a guardrail meant to keep Grafana's Helm values minimal. → **[Mitigation]** Narrowed, not removed — the scenario still names exactly two allowed sidecars (datasource, dashboard); anything beyond those two remains a spec violation.
- **[Risk]** A native Prometheus alert with no Alertmanager is invisible to anyone not actively looking at Prometheus's `/alerts` page or Grafana's alerting UI — it can't page anyone. → **[Mitigation]** Accepted for this phase; the done-when is "fires on a manual test condition," not "notifies a human." Revisit ADR-0010 again if/when a real notification need shows up.
- **[Risk]** `increase()` over a 5-minute window means the alert can stay `firing` for up to 5 minutes after the single triggering request, which could read as "stuck" during a live demo. → **[Mitigation]** Accepted: it's the same window that buys reliable detection; the alternative (a shorter window) reintroduces the no-data gap this design exists to avoid.

## Migration Plan

1. Add `deploy/observability-config/grafana-dashboard-hello/` (`configmap.yaml` with the dashboard JSON under data key `hello.json`, labeled `grafana_dashboard: "1"`; `kustomization.yaml`)
2. Add `deploy/apps/grafana-dashboard-hello.yaml` (sync-wave `"2"`), mirroring `deploy/apps/grafana-datasource.yaml`
3. Modify `deploy/apps/grafana.yaml`: add `sidecar.dashboards.enabled: true` alongside the existing `sidecar.datasources.enabled`
4. Modify `deploy/apps/prometheus.yaml`: add `serverFiles."alerting_rules.yml"` with the non-2xx-rate rule group
5. Commit and let ArgoCD sync — no manual `kubectl apply`, per `deploy/CLAUDE.md`
6. Verify, in order: dashboard panels render live data in Grafana → `curl -X POST` hello's root endpoint → confirm the rule transitions `pending`/`firing` in Prometheus's `/alerts` view within 5 minutes → confirm the same rule is visible read-only under Grafana's data-source-managed alerting view

Rollback is low-risk: reverting the four manifest changes removes the dashboard and rule with no data-loss exposure, since nothing introduced here is stateful (ConfigMaps and Helm values only).

## Open Questions

None blocking — the label set and alert-window math were verified against the live cluster before this design was written, not assumed.
