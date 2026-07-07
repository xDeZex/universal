## ADDED Requirements

### Requirement: Alloy runs as an Observability component, one DaemonSet pod per node

Alloy SHALL be installed via a dedicated ArgoCD Application (`deploy/apps/alloy.yaml`) sourcing the upstream `grafana/alloy` Helm chart directly, deployed as a DaemonSet, running in the shared `observability` namespace (ADR-0008).

#### Scenario: Happy path — Application synced and Alloy healthy

- **WHEN** the `alloy` Application is synced by ArgoCD
- **THEN** an Alloy pod runs on every node in the cluster and reports healthy

#### Scenario: Error/rejection — not a single Deployment replica

- **WHEN** the Application's Helm values are reviewed
- **THEN** the controller type SHALL be `daemonset`, not `deployment`, so log tailing scales with node count if the cluster grows beyond one node

#### Scenario: Contract — Helm chart sourced directly

- **WHEN** the ArgoCD Application spec is inspected
- **THEN** its `source` SHALL reference the upstream `grafana/alloy` Helm chart repo (not a git path of vendored manifests)

### Requirement: Alloy discovers and tails pod logs across all namespaces

Alloy SHALL discover pods cluster-wide via the Kubernetes API (no namespace restriction), tail each discovered pod's container log files via a hostPath mount to the node's pod log directory, and label each resulting log stream with `namespace`, `pod`, and `container`.

#### Scenario: Happy path — a pod's logs appear labeled in Loki

- **WHEN** any pod in any namespace writes a line to stdout
- **THEN** that line is ingested into Loki with `namespace`, `pod`, and `container` labels matching the source pod

#### Scenario: Error/rejection — no namespace allowlist/denylist narrows discovery

- **WHEN** Alloy's Kubernetes pod discovery configuration is reviewed
- **THEN** it SHALL NOT scope discovery to a subset of namespaces; all namespaces SHALL be eligible for discovery

#### Scenario: Contract — hostPath mount targets the node's pod log directory

- **WHEN** Alloy's DaemonSet volume configuration is inspected
- **THEN** it SHALL mount the node's `/var/log/pods` directory read-only, matching where kubelet writes container logs

### Requirement: Alloy ships logs directly to Loki, independent of otel-collector

Alloy SHALL push discovered log streams directly to Loki's push API. otel-collector's existing `otlp`-receiver logs pipeline SHALL remain unused by this path — no log signal SHALL be routed through otel-collector.

#### Scenario: Happy path — logs reach Loki without passing through otel-collector

- **WHEN** Alloy's log pipeline configuration is inspected
- **THEN** its write target SHALL be Loki's in-cluster Service directly, not otel-collector's OTLP endpoint

#### Scenario: Error/rejection — otel-collector's logs pipeline is not modified

- **WHEN** `deploy/apps/otel-collector.yaml`'s Helm values are reviewed
- **THEN** its `logs` pipeline (`otlp` receiver → `debug` exporter) SHALL be unchanged by this work

### Requirement: Resource requests/limits are set against the phase RAM budget

The Alloy pod SHALL specify explicit CPU/memory requests and limits, sized to fit within the Phase 1 epic's (#14) documented RAM headroom rather than left at chart defaults.

#### Scenario: Happy path — pod scheduled within defined bounds

- **WHEN** the Alloy pod is scheduled
- **THEN** it has non-empty `resources.requests` and `resources.limits` for both CPU and memory

#### Scenario: Error/rejection — no unbounded deployment

- **WHEN** the Helm values are reviewed
- **THEN** they SHALL NOT omit `resources`, leaving the pod unbounded against the shared node's budget
