## Why

Cluster and pod logs aren't queryable anywhere today — `hello`'s logs (and every other pod's) only exist as plain stdout captured by kubelet on the node, readable only via `kubectl logs` with no history once a pod is gone. Metrics (#61-#65) and a stub logs pipeline (#63) already exist in the observability stack, but nothing stores or indexes logs. This closes that gap (#66, part of the Phase 1 observability epic #14).

## What Changes

- Deploy Loki as an ArgoCD Application (`deploy/apps/loki.yaml`), SingleBinary mode, filesystem storage on the existing `observability-retain` StorageClass — no S3/minio, mirroring how Prometheus is deployed.
- Deploy Grafana Alloy as an ArgoCD Application (`deploy/apps/alloy.yaml`), running as a DaemonSet (one pod, since the `miniser` k3s cluster is single-node). Alloy discovers pods across **all** namespaces via the k8s API, tails their container log files (hostPath-mounted `/var/log/pods`), labels each log stream with `namespace`/`pod`/`container`, and pushes directly to Loki's push API.
- `otel-collector` is untouched: its existing `otlp` logs pipeline (receiver → debug exporter, from #63) stays a stub. Logs reach Loki entirely through Alloy's own path, not through the collector.
- Add a Loki datasource to Grafana via the existing sidecar-ConfigMap pattern (`deploy/observability-config/grafana-datasource/`), alongside the existing Prometheus datasource.
- Start conservative on retention/size: 3-day retention, 5Gi PVC for Loki (shorter than Prometheus's 7d given logs are much higher-volume per unit time than metric samples; disk isn't scarce on this box, this is a deliberate starting point, not a forced limit).

## Capabilities

### New Capabilities
- `loki`: Loki log storage, deployed as an ArgoCD Application in SingleBinary mode with filesystem storage, 3d retention, 5Gi PVC on `observability-retain`.
- `alloy`: Grafana Alloy log-shipping agent, deployed as an ArgoCD Application (DaemonSet), discovering and tailing all pods cluster-wide and pushing labeled log streams to Loki.

### Modified Capabilities
- `grafana-datasource`: add a Loki datasource, provisioned the same way the existing Prometheus datasource is (sidecar-discovered ConfigMap, independent Application lifecycle).

## Impact

- New: `deploy/apps/loki.yaml`, `deploy/apps/alloy.yaml`.
- Modified: `deploy/observability-config/grafana-datasource/configmap.yaml` (or a new ConfigMap alongside the existing one) to add the Loki datasource.
- No changes to `otel-collector`, `hello`, or any other existing service/manifest.
- Out of scope: `hello` switching to OTel-SDK-based logging for trace/log correlation — tracked separately as #82, which depends on this change plus trace instrumentation that doesn't exist yet.
