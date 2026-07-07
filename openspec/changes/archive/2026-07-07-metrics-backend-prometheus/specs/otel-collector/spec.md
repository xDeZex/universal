## REMOVED Requirements

### Requirement: Debug exporter only, no backend wired
**Reason**: A real metrics backend (Prometheus) now exists. A blanket "debug only" rule covering all three signal types no longer reflects the collector's behavior now that metrics has a persistent destination.
**Migration**: Replaced by two scoped requirements below — "Metrics pipeline exports to Prometheus" and "Traces and logs pipelines remain debug-only pending their backends" — which state the same no-backend-yet rule for traces/logs while carving metrics out explicitly.

## ADDED Requirements

### Requirement: Metrics pipeline exports to Prometheus

The collector's metrics pipeline SHALL export exclusively to a `prometheusremotewrite` exporter pointed at the Prometheus Observability component's remote-write endpoint. No other exporter SHALL be referenced by the metrics pipeline.

#### Scenario: Happy path — metrics payload forwarded to Prometheus

- **WHEN** an OTLP metrics payload is received on either receiver endpoint
- **THEN** its data points are forwarded to Prometheus via the `prometheusremotewrite` exporter and become queryable there within one export interval

#### Scenario: Error/rejection — no other metrics exporter configured

- **WHEN** the metrics pipeline's exporter configuration is reviewed
- **THEN** it SHALL NOT reference `debug` or any exporter other than `prometheusremotewrite`

#### Scenario: Contract — remote-write endpoint matches Prometheus's Service

- **WHEN** the `prometheusremotewrite` exporter's configuration is inspected
- **THEN** its endpoint SHALL match the Prometheus Observability component's in-cluster Service DNS name and remote-write path

### Requirement: Traces and logs pipelines remain debug-only pending their backends

The collector's traces and logs pipelines SHALL continue to export exclusively to the `debug` exporter, unchanged, until #66 (logs) and #67 (traces) wire real backends.

#### Scenario: Happy path — traces/logs payload logged to debug output

- **WHEN** an OTLP traces or logs payload is received on either receiver endpoint
- **THEN** its contents appear in the collector pod's own container logs via the `debug` exporter

#### Scenario: Error/rejection — no backend exporter configured for traces or logs

- **WHEN** the traces or logs pipeline's exporter configuration is reviewed
- **THEN** neither SHALL reference any exporter other than `debug`
