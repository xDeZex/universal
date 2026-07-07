# Bare Prometheus chart over kube-prometheus-stack

For the observability epic's metrics backend (#62), we chose the upstream `prometheus-community/prometheus` chart (server only) over `kube-prometheus-stack`. We decided this because every component in this epic has landed as one focused piece per ArgoCD Application — bundling Alertmanager, node-exporter, kube-state-metrics, the Prometheus Operator's CRDs, and a second Grafana would break that pattern and pre-empt #64, which owns deploying Grafana separately.

## Considered options

- **`kube-prometheus-stack`** — rejected: bundles Alertmanager, node-exporter, kube-state-metrics, and its own Grafana, none of which are wanted yet. #65's alerting need can be met later by adding Alertmanager (or an equivalent) as its own component when alerting actually lands, rather than accepting the whole bundle now for one piece of it.

## Consequences

- #65 (first dashboard + alert) will need to add Alertmanager as a separate component when it lands, since the bare chart doesn't provide one.
