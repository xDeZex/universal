## Context

hello already pushes OTLP metrics to the otel-collector (#61), which currently only logs them via its `debug` exporter (#63) — nothing persists, nothing is queryable. `docs/adr/0008-observability-namespace.md` already fixes the namespace (`observability`, shared across the whole stack) and `docs/adr/0010-bare-prometheus-over-kube-prometheus-stack.md` already fixes the backend and chart shape (bare `prometheus-community/prometheus`, not the Operator-based stack). This design covers the remaining "how": where the StorageClass lives, sync ordering, retention/resource sizing, and how the otel-collector spec's exporter requirement is restructured.

## Goals / Non-Goals

**Goals:**
- Prometheus running healthy in `observability`, persisting metrics to a PVC that survives an accidental Application deletion.
- The otel-collector's metrics pipeline pushing to Prometheus via `prometheusremotewrite`, replacing `debug` for that signal only.
- A reusable storage convention (`observability-retain` StorageClass) that Loki (#66) can adopt without re-deciding reclaim policy.

**Non-Goals:**
- Alertmanager, dashboards, or alerts — that's #65.
- Grafana — that's #64.
- Multi-replica or HA Prometheus — the cluster is single-node; a single pod with a local PVC is sufficient.
- Long-term storage or downsampling — 7-day retention is deliberately short-lived, revisit only if a real need for longer history shows up.

## Decisions

- **New `observability-retain` StorageClass, not the cluster default.** Every component so far has been stateless, so the cluster default (`local-path`, `reclaimPolicy: Delete`) never mattered. Prometheus's TSDB is the first data in this cluster actually worth protecting from an accidental `prune: true` deletion of its Application. Rather than special-case Prometheus, this introduces a `Retain`-policy class (same `rancher.io/local-path` provisioner — no new CSI driver) that any Observability component needing durable storage can opt into, so Loki (#66) doesn't have to redecide this later.
  - *Alternative considered*: bundle the StorageClass directly into `deploy/apps/prometheus.yaml` since Prometheus is the only consumer today — rejected. It's a shared observability-stack resource in intent (Loki needs it next), and mixing "install third-party software" (the Prometheus chart) with "author platform config" (the StorageClass) in one Application blurs the Infra-component/Infra-config-style split this project already keeps everywhere else. Given it as authored config, no new software, scoped to the observability stack, it fits the newly-introduced **Observability config** category (see `CONTEXT.md`): `deploy/observability-config/storage/`, its own ArgoCD Application under `deploy/apps/`.
- **Sync-wave ordering: `observability-storage` at wave `0`, `prometheus` at wave `1`.** Mirrors the existing `cert-manager` (wave 0) → `letsencrypt-issuer` (wave 1) precedent for "config that depends on something else existing first." The StorageClass has no dependencies of its own, same as `otel-collector`/`sealed-secrets`; Prometheus's PVC needs the class to exist to bind against it.
- **Retention fixed at 7 days** via the chart's server retention setting. Chosen for a single-Service, single-node, "prove the pipe" stage — long enough to look back over a week, short enough not to think about disk growth yet. `local-path-provisioner` doesn't enforce PVC-declared size as a real quota (see [rancher/local-path-provisioner#107](https://github.com/rancher/local-path-provisioner/issues/107)), so the real ceiling is retention × ingest rate against actual disk, not the PVC's nominal size.
- **PVC size is a modest, non-binding declaration** (a few GiB) rather than a carefully computed number — the provisioner doesn't enforce it as a hard cap, so getting it exactly right upfront isn't load-bearing the way it would be on a quota-enforcing StorageClass.
- **otel-collector's exporter requirement is restructured, not patched.** The existing "debug exporter only, no backend wired" requirement covered all three signal types with one blanket rule. Rather than bolt a metrics exception onto that wording, the spec delta removes it and adds two scoped requirements — one for metrics (→ Prometheus), one for traces/logs (→ still debug, pending #66/#67) — so a future reader sees an intentional per-signal split, not a stale rule with an exception carved out of it.

## Risks / Trade-offs

- **[Risk]** First PVC-backed component in this cluster — dynamic provisioning + `WaitForFirstConsumer` binding behavior with `local-path` is unverified in practice here. → **[Mitigation]** Verify post-deploy the same way `otel-collector` did: confirm the pod schedules, binds its PVC, and reaches `Running`/`Ready` after ArgoCD syncs, as an explicit last task.
- **[Risk]** `Retain` policy means a PV is left behind (consuming disk) if the Application is ever deliberately deleted. → **[Mitigation]** Accepted: this is the whole point of choosing `Retain` over `Delete` here. Cleanup, if ever wanted, is a manual `kubectl delete pv`.
- **[Risk]** Bare chart has no Alertmanager, which #65 will eventually want. → **[Mitigation]** Already accepted and recorded in ADR-0010's Consequences — #65 adds it as its own component when alerting actually lands.
- **[Risk]** Resource requests/limits picked before real traffic exists may be wrong in either direction. → **[Mitigation]** Same low-stakes call `otel-collector`'s design made: a one-line Helm-values change to correct later, not architectural.

## Migration Plan

1. Add `deploy/observability-config/storage/` (`storageclass.yaml`, `kustomization.yaml`) and `deploy/apps/observability-storage.yaml` (sync-wave `0`).
2. Add `deploy/apps/prometheus.yaml` (sync-wave `1`), PVC referencing `observability-retain`, retention `7d`.
3. Modify `deploy/apps/otel-collector.yaml`: metrics pipeline's `exporters` changes to `[prometheusremotewrite]`; add the `prometheusremotewrite` exporter config pointed at Prometheus's in-cluster Service. Traces/logs pipelines untouched.
4. Commit and let ArgoCD sync — no manual `kubectl apply`, per `deploy/CLAUDE.md`.
5. Verify, in order: `observability-retain` StorageClass exists → Prometheus pod `Running`/`Ready` with a bound PVC → collector logs show successful remote-write pushes (no errors) → Prometheus's query API returns a metric with `service.name="hello"`.

Rollback is low-risk: reverting the collector's exporter back to `debug` is a one-line change; deleting the `prometheus` Application only loses data if the orphaned PV (left behind by `Retain`) is also manually removed.

## Open Questions

- Exact PVC size (a few GiB, indicative) — not blocking, tighten once real usage is visible post-deploy, same as `otel-collector`'s resource values were.
