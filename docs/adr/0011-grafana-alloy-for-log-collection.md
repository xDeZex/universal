# Grafana Alloy for log collection, revisiting ADR-0009 for logs only

For log collection (#66, part of the Phase 1 observability epic, #14), we chose Grafana Alloy, deployed as a DaemonSet tailing `/var/log/pods` via hostPath and pushing directly to Loki, over extending otel-collector with a filelog receiver. This is the revisit ADR-0009 named as its own trigger: *"Revisit the vendor choice if Alloy's native scraping becomes compelling once Loki (#66) needs log collection... since node-local log/host-metric scraping is the textbook DaemonSet case."*

The `miniser` cluster is single-node, so the "DaemonSet agent + Deployment gateway" split that matters on multi-node clusters collapses here — a filelog receiver could have been added to the existing otel-collector Application directly rather than requiring a second collector instance. Once that cost is removed, the choice becomes a config-assembly question: filelog receiver + `k8sattributes` processor (to attach namespace/pod/container labels) + a `file_storage` extension backed by a new PVC (to checkpoint read-offsets across collector restarts — the collector has no PVC today) + `lokiexporter`, versus Alloy shipping k8s discovery, labeling, and checkpointing as defaults. We chose Alloy because it's meaningfully less manual assembly for the same outcome, and this project's stated learning goal — going deep on the OTel collector specifically — is already served by otel-collector's existing metrics pipeline; there's no strong reason to also make it the logs tool when a purpose-built one is simpler to operate correctly.

This choice is scoped to logs only. otel-collector remains the metrics/traces tool (ADR-0009 stands for that scope); Alloy is not being evaluated as a replacement for it, and otel-collector's existing `otlp`-receiver `logs` pipeline (`otlp` → `debug`, from #63) stays an unused stub — no log signal is routed through it.

## Considered options

- **Extend otel-collector with a filelog receiver** — rejected: requires assembling a filelog receiver, `k8sattributes` processor, `file_storage` extension (plus a new PVC for checkpointing), and `lokiexporter` by hand for the same outcome Alloy provides out of the box. Doesn't serve the project's OTel-collector learning goal any further than the existing metrics pipeline already does.
- **Grafana Alloy using `loki.source.kubernetes`** (Kubernetes API log streaming, no hostPath/system privileges required) — rejected: doesn't match the DaemonSet + hostPath-tailing shape that scales naturally with node count, and reads container logs through the API server rather than directly off the node.

## Consequences

- Two independent telemetry paths now exist (otel-collector for metrics/traces, Alloy for logs) rather than one unified pipeline. Each path is simple and independently debuggable, which is the trade-off ADR-0009 already anticipated and accepted.
