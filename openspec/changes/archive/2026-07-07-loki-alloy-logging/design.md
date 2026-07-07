## Context

Issue #66 (part of the Phase 1 observability epic, #14) asks for a decision between two log-routing paths — a filelog receiver on otel-collector, or a separate agent (the issue names Promtail/Alloy) — plus deploying Loki and wiring the chosen path to it.

Two things established during exploration change the shape of that decision from how the issue frames it:

- **The cluster (`miniser`) is single-node.** The "DaemonSet agent + Deployment gateway" split that matters on multi-node clusters collapses here: a DaemonSet and a Deployment both produce exactly one pod, on the only node that exists. So a filelog-receiver approach would *not* require a second collector instance — it could be added to the existing otel-collector Application directly (hostPath mount + `mode: daemonset`, cosmetic today).
- **otel-collector's existing `logs` pipeline (`otlp` receiver → `debug` exporter, from #63) is a stub nothing feeds.** No app emits OTel logs today (`hello` logs via plain `log.Println` to stdout, entirely outside OTel). This work is "get logs into the stack for the first time," not "reroute logs already flowing through OTel."

ADR-0009 (choosing otel-collector-contrib over Alloy for the metrics pipeline) explicitly named this moment as its own revisit trigger: *"Revisit the vendor choice if Alloy's native scraping becomes compelling once Loki (#66) needs log collection... since node-local log/host-metric scraping is the textbook DaemonSet case."* This design is that revisit — scoped to logs only, not a reversal of ADR-0009 for metrics/traces.

## Goals / Non-Goals

**Goals:**
- Get cluster-wide pod logs (every namespace, not just `services`) into a queryable store, satisfying #66's "done when."
- Reuse the existing `observability-retain` StorageClass / SingleBinary pattern already established by Prometheus, rather than introducing object storage or a distributed mode this box doesn't need.
- Keep otel-collector's existing metrics/traces responsibilities untouched — this change adds a new, independent path for logs rather than extending the collector.

**Non-Goals:**
- `hello` (or any service) emitting logs via the OTel logs SDK — tracked separately as #82, which depends on this change plus trace instrumentation that doesn't exist yet (no service currently creates spans).
- Structured (JSON) logging in `hello` — plain-text log lines are filterable in Loki via LogQL line filters (`|= "text"`); structured fields are a later, separate concern.
- Multi-node scaling considerations — noted where relevant, not designed for, since the cluster is single-node today.

## Decisions

### Alloy over extending otel-collector's filelog receiver

**Chosen:** Grafana Alloy, deployed as a DaemonSet, tailing `/var/log/pods` via hostPath and pushing directly to Loki.

**Alternative considered — filelog receiver on otel-collector:** Once the single-node reality removes the "extra gateway/agent component" cost, this becomes a config-assembly question: filelog receiver + `k8sattributes` processor (to attach namespace/pod/container labels) + a `file_storage` extension backed by a new PVC (to checkpoint read-offsets across collector restarts — the collector has no PVC today) + `lokiexporter` (already available; the chart already uses the `-contrib` image). Rejected because it's meaningfully more manual assembly for the same outcome Alloy provides out of the box, and this project's stated learning goal — going deep on the OTel collector specifically — is already served by otel-collector's existing metrics pipeline; there's no strong reason to also make it the logs tool when a purpose-built one is simpler to operate correctly (Alloy ships k8s discovery, labeling, and checkpointing as defaults, not hand-wired config).

This choice is logs-only. otel-collector remains the metrics/traces tool; Alloy is not being evaluated as a replacement for it.

### Loki SingleBinary, filesystem storage, mirroring Prometheus's pattern

**Chosen:** `grafana/loki` chart, `SingleBinary` deployment mode, filesystem-backed chunks/index on a PVC (`observability-retain`, 5Gi).

**Alternative considered — SimpleScalable/distributed mode with object storage:** Rejected — this mode exists for horizontal read/write scaling and S3-compatible storage, neither of which this single-node, single-disk box needs or has. It would also introduce a new storage dependency (minio) purely to satisfy a mode built for a scale this deployment doesn't operate at.

### All-namespace scope, filtered at the config level

**Chosen:** Alloy discovers and tails pods across every namespace from day one.

**Alternative considered — narrow to `services` + `observability` initially:** Considered during exploration but not chosen, on the reasoning that namespace scope is a cheap, reversible relabel/filter rule in Alloy's config (not a structural redeploy), so there's little to be gained by starting narrow — full visibility from the start is more useful and costs nothing to walk back later if log volume turns out to be a problem.

### Conservative retention/sizing to start

**Chosen:** 3-day retention, 5Gi PVC for Loki; resource requests/limits in the same order of magnitude as the existing observability components (Loki: 100m/256Mi request, 500m/512Mi limit; Alloy: 50m/64Mi request, 200m/128Mi limit).

**Rationale:** The node's actual available memory (`free -h`: 6.8Gi available, matching the epic's original ~7.4Gi estimate — `kubectl top node`'s 56%-used figure was misleading, counting reclaimable page cache) confirms there's room, but logs are much higher-volume per unit time than metric samples, so copying Prometheus's 7d retention without evidence of real log volume on this box would be guessing. Disk itself isn't scarce (~416Gi ephemeral storage available) — the conservative starting point is a discipline choice, not a forced constraint, and is cheap to raise once real volume is observed.

## Risks / Trade-offs

- **[Risk]** All-namespace scope means noisy/high-volume infra components (e.g. `argocd-repo-server`, `traefik`) count against the 3-day retention window just as much as `hello`'s logs, potentially crowding out app logs sooner than expected. → **Mitigation**: retention and scope are both cheap config changes (not redeploys); revisit either once real volume is visible in Grafana/Loki metrics.
- **[Risk]** Two independent telemetry paths now exist (otel-collector for metrics/traces, Alloy for logs) rather than one unified pipeline — slightly more surface area to reason about when something breaks. → **Mitigation**: this is the same shape ADR-0009 anticipated and accepted; each path is simple and independently debuggable, which is arguably easier to reason about than one collector doing everything.
- **[Risk]** No object storage means Loki's data is tied to this one node's disk — a node loss loses log history (same exposure Prometheus already has under the same storage pattern). → **Mitigation**: accepted as consistent with the rest of this observability stack's existing risk profile; not a new exposure introduced by this change.

## Open Questions

- None outstanding — all decisions from exploration were resolved before this proposal was written. A new ADR documenting the Alloy-for-logs choice (revisiting ADR-0009's named trigger) should be authored as part of implementation.
