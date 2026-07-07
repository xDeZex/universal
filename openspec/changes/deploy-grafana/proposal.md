## Why

Prometheus (#62) is deployed and receiving hello's metrics via otel-collector, but there's no way to query or visualize them. Grafana is the last piece needed to close the loop for #14's Phase 1 epic and satisfy #64: a queryable, visual front end onto the metrics backend, reachable without shelling into the cluster.

## What Changes

- Deploy Grafana as an ArgoCD Application (`deploy/apps/grafana.yaml`), sourcing the upstream `grafana/grafana` Helm chart directly, as an Observability component in the shared `observability` namespace (ADR-0008)
- Expose Grafana publicly at `xdezex.duckdns.org/grafana` via the chart's native `ingress` values, reusing the existing host-scoped TLS secret (ADR-0007) — no new DNS record or router change needed
- Lock down auth for the public instance: anonymous access disabled, self-signup disabled; the only account is `admin`, with a real password sealed via SealedSecret (bitnami sealed-secrets, already installed) and wired in through a multi-source Application (chart + local git path for the secret)
- Run Grafana with no persistence — dashboards are disposable until #65 defines them as code
- Wire a Prometheus datasource via a separate Observability config item (`deploy/observability-config/grafana-datasource/` + `deploy/apps/grafana-datasource.yaml`), picked up dynamically by the chart's datasource sidecar rather than baked into `grafana.yaml`'s own values
- Size resource requests/limits against the Phase 1 RAM budget (100m/128Mi request, 500m/256Mi limit), consistent with Prometheus and otel-collector

## Capabilities

### New Capabilities
- `grafana`: Grafana runs as an Observability component (ArgoCD Application, `grafana/grafana` chart), publicly reachable over HTTPS at `xdezex.duckdns.org/grafana`, with anonymous access and self-signup disabled and admin credentials sourced from a SealedSecret
- `grafana-datasource`: A Prometheus datasource is provisioned into Grafana via a dedicated Observability config Application, independent of Grafana's own Application lifecycle

### Modified Capabilities
(none — Prometheus's and otel-collector's existing contracts are unchanged; Grafana only reads from Prometheus, it doesn't alter how Prometheus is deployed or configured)

## Impact

- New files: `deploy/apps/grafana.yaml`, `deploy/apps/grafana-datasource.yaml`, `deploy/observability-config/grafana-datasource/` (kustomization + ConfigMap), a SealedSecret manifest for the admin password
- No changes to `services/`, the app, or existing Applications (`prometheus.yaml`, `otel-collector.yaml` untouched)
- New public-internet-facing surface: `xdezex.duckdns.org/grafana` — a real login is now a real security boundary, unlike LAN-only tooling (ArgoCD's UI) elsewhere in this cluster
- Phase 1 RAM budget: +128Mi request / +256Mi limit on top of the ~384Mi already committed (otel-collector + Prometheus), well within the ~7.4Gi headroom
