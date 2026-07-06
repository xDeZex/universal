# OpenTelemetry Collector Contrib over Grafana Alloy, in Deployment mode

For the otel-collector Observability component (#63), we chose the upstream OpenTelemetry Collector Contrib distribution over Grafana Alloy, deployed via its Helm chart in `mode: deployment`. We decided this because the project's stated goal is learning the CNCF-native observability pipeline itself, not just getting a working Grafana stack — Alloy's main edge, native Prometheus/Loki scrape configs, doesn't help yet since this issue wires up only the `otlp` receiver with a debug exporter and no backend. `deployment` mode matches that: it's a push target for OTLP from Services, not a node-local scraper. Revisit the vendor choice if Alloy's native scraping becomes compelling once Loki (#66) needs log collection, and revisit the mode (or add a second collector) at that same point, since node-local log/host-metric scraping is the textbook DaemonSet case.

## Considered options

- **Grafana Alloy** — rejected for now: its advantage is native Prometheus/Loki scrape configs, which nothing in this issue or its immediate successors (#61, #62) uses; it would also introduce a second config DSL (River) alongside the Collector's standard receivers/processors/exporters YAML.
- **`mode: daemonset`** — rejected for now: no receiver in this issue scrapes node-local signals; the cluster is also single-node today, so the choice has no practical effect yet either way.
