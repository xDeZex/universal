## ADDED Requirements

### Requirement: Alert rule fires on hello's non-2xx response rate

Prometheus SHALL be configured with a native alerting rule (via `serverFiles."alerting_rules.yml"` in the Helm values), evaluating whether hello's non-2xx response rate is nonzero, with no Alertmanager involved (ADR-0010).

#### Scenario: Happy path — alert fires on a manually-triggered non-2xx response

- **WHEN** a non-GET request is sent to hello's root endpoint, producing a 405 response, and up to 5 minutes elapse
- **THEN** the rule transitions to `firing` in Prometheus's `/alerts` view

#### Scenario: Error/rejection — window sized against the push interval, not a scrape default

- **WHEN** the rule's `expr` is reviewed
- **THEN** its range-vector window SHALL be at least 4x hello's OTel export interval (60s default), not a short window borrowed from typical scrape-interval conventions (see `deploy/CLAUDE.md`)

#### Scenario: Contract — no Alertmanager wired

- **WHEN** the Prometheus Helm values are reviewed
- **THEN** `alertmanager.enabled` SHALL remain `false` and no `alerting.alertmanagers` target SHALL be configured; the rule fires and is visible directly in Prometheus without a notification hop
