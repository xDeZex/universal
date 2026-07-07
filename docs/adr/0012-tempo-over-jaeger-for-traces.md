# Tempo over Jaeger for traces backend, monolithic mode

For the observability epic's traces backend (#67), we chose Grafana Tempo, deployed via the monolithic `grafana/tempo` chart, over Jaeger. This continues the pattern ADR-0009/0010/0011 already established: pick the option that fits the existing Grafana-ecosystem stack (Prometheus + Loki + Grafana already deployed, all via `grafana`/`prometheus-community` charts with native Grafana datasource integration) over introducing a new vendor, and prefer the simplest chart shape that fits a single-node cluster. Tempo mirrors Loki's own shape almost exactly — monolithic/single-binary deploy, filesystem-backed storage on a PVC, no gateway in front — the same shape Loki was deployed in (`deploy/apps/loki.yaml`), though that choice was never itself captured in an ADR.

## Considered options

- **Jaeger** — rejected: a separate vendor/ecosystem alongside otel-collector-contrib and the Grafana stack, with its own storage backend decision to make (badger for all-in-one vs Elasticsearch/Cassandra for a "real" deployment). Its main edge — a more mature standalone tracing UI — doesn't matter much when Grafana, with Loki and Prometheus already wired as datasources, is the UI being used regardless.
- **`grafana/tempo-distributed`** (microservices chart: separate ingester/querier/compactor/distributor) — rejected for the same reason Loki's `deploy/apps/loki.yaml` runs in `SingleBinary` mode rather than the distributed chart: no signal in this issue needs it, and the cluster is single-node.

## Consequences

- Trace-to-logs/metrics correlation (Grafana exemplars) and a deliberate sampling strategy are explicitly out of scope for #67 and tracked separately (#87, #88) rather than decided here.
