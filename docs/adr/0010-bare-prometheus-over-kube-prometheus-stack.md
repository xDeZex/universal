# Bare Prometheus chart over kube-prometheus-stack

For the observability epic's metrics backend (#62), we chose the upstream `prometheus-community/prometheus` chart (server only) over `kube-prometheus-stack`. We decided this because every component in this epic has landed as one focused piece per ArgoCD Application — bundling Alertmanager, node-exporter, kube-state-metrics, the Prometheus Operator's CRDs, and a second Grafana would break that pattern and pre-empt #64, which owns deploying Grafana separately.

## Considered options

- **`kube-prometheus-stack`** — rejected: bundles Alertmanager, node-exporter, kube-state-metrics, and its own Grafana, none of which are wanted yet. #65's alerting need turned out not to require Alertmanager at all — see Consequences.

## Consequences

- #65's alert fires as a native Prometheus rule with no Alertmanager: the rule evaluates and transitions to pending/firing directly in Prometheus, which is sufficient for a rule with no routing/notification requirement. Alertmanager (or an equivalent) is only needed if a future alert needs to notify somewhere.
