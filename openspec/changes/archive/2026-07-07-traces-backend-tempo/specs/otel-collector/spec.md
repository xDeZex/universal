## MODIFIED Requirements

### Requirement: Logs pipeline remains debug-only, an intentionally unused stub

The collector's `logs` pipeline SHALL continue to export exclusively to the `debug` exporter. This is permanent, not pending a future backend: ADR-0011 routes log collection through Alloy directly to Loki, bypassing the collector entirely, so this pipeline stays an unused stub by design.

#### Scenario: Happy path — logs payload logged to debug output

- **WHEN** an OTLP logs payload is received on either receiver endpoint
- **THEN** its contents appear in the collector pod's own container logs via the `debug` exporter

#### Scenario: Error/rejection — no backend exporter configured for logs

- **WHEN** the logs pipeline's exporter configuration is reviewed
- **THEN** it SHALL NOT reference any exporter other than `debug`

## ADDED Requirements

### Requirement: Traces pipeline exports to Tempo

The collector's `traces` pipeline SHALL export exclusively to an `otlphttp` exporter pointed at the Tempo Observability component's OTLP http endpoint. No other exporter SHALL be referenced by the traces pipeline.

#### Scenario: Happy path — traces payload forwarded to Tempo

- **WHEN** an OTLP traces payload is received on either receiver endpoint
- **THEN** it is forwarded to Tempo via the `otlphttp` exporter and becomes queryable there

#### Scenario: Error/rejection — no other traces exporter configured

- **WHEN** the traces pipeline's exporter configuration is reviewed
- **THEN** it SHALL NOT reference `debug` or any exporter other than `otlphttp`

#### Scenario: Contract — endpoint matches Tempo's Service

- **WHEN** the `otlphttp` exporter's traces endpoint is inspected
- **THEN** it SHALL match the Tempo Observability component's in-cluster Service DNS name and OTLP http port
