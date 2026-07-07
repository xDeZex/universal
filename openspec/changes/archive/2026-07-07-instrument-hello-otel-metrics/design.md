## Context

`otel-collector` (#63) is deployed in the `observability` namespace with an `otlp` receiver on both grpc (4317) and http (4318), exporting everything to `debug` only — confirmed live: `otel-collector-opentelemetry-collector.observability.svc.cluster.local` exposes both ports. `hello` (#61) is the first service to send it anything. `hello` today is a single-file `main` package with two trivial handlers (`/`, `/healthz`) and no dependencies beyond the standard library; it ships on a `scratch` base image (ADR-0003) because it makes no outbound TLS calls.

## Goals / Non-Goals

**Goals:**
- Get real OTLP metric payloads from `hello` into the collector's debug output, proving the pipe works
- Keep the instrumentation surface minimal — this issue is plumbing, not "add a dashboard's worth of business metrics"

**Non-Goals:**
- Traces or logs (later phases, #66/#67)
- A shared/reusable telemetry setup across services — `hello` is the only service today; extract a shared package or Kustomize component only when a second service needs one
- Real health-check logic for `/healthz` — it has none today, so there's nothing meaningful to instrument there yet

## Decisions

**HTTP OTLP exporter (`otlpmetrichttp`), not grpc.** Both are available on the collector; either would work. HTTP was chosen for `hello` specifically (not a blanket rule for future services).

**Plaintext (`http://`) endpoint, not TLS.** This isn't just simpler — it's required to stay compliant with ADR-0003: `hello` ships on `scratch` because it makes no outbound TLS calls, and `scratch` has no CA cert bundle. An `https://` collector endpoint would force a switch to `distroless/static` or bundling certs. Confirmed no `NetworkPolicy` in the cluster restricts `services` → `observability` traffic, so the plaintext cross-namespace call needs no additional network plumbing.

**`otelhttp` contrib wrapper instead of hand-rolled middleware.** `go.opentelemetry.io/contrib/instrumentation/net/http/otelhttp` emits semconv-compliant `http.server.*` metrics with no bespoke counter/histogram code — and those names will already match what a future Grafana dashboard (#65) queries.

**Only `/` is instrumented; `/healthz` is not.** `/healthz` unconditionally returns 200 (no dependency or state check exists), so wrapping it would only add k8s-probe-driven volume with zero failure signal. Revisit if `/healthz` ever grows a real check.

**`service.name` via env var, `service.version` via the existing `version` Go var.** `service.name` is a constant ("hello") — trivial as an env var. `service.version` needs the git SHA, which `hello` already computes via `-ldflags` into the `version` variable (same value the `/` endpoint returns) — reading it directly in Go avoids CI having to duplicate that value into a second env var kept in sync with the image tag.

**Endpoint + service name delivered via a `ConfigMap` local to `deploy/services/hello/`.** No shared Kustomize component across services yet — `hello` is the only consumer today. Extract a shared component later if/when a second service needs the same values; that's a mechanical, low-cost move at that point.

**Generic `OTEL_EXPORTER_OTLP_ENDPOINT`, not the metrics-specific variant.** The generic var makes the SDK auto-append `/v1/metrics`; if `hello` later emits traces too, the same ConfigMap value works unchanged.

**New `services/hello/internal/telemetry` subpackage**, not a same-package file. This is `hello`'s first subpackage — chosen over stuffing the ~20 lines of MeterProvider/exporter/resource bootstrap into `main.go` or a same-package second file, to keep `main.go`'s "thin" convention unambiguous (`services/CLAUDE.md`) and give the SDK setup its own testable boundary.

**Tests use `metric.NewManualReader()`, not the real OTLP exporter.** There's no way to assert wire-level export in a unit test; the pattern is an in-memory `MeterProvider` backed by a manual reader, driven through the existing `httptest` handler tests, asserting the `otelhttp`-recorded instruments directly.

**Adjacent finding, tracked separately (#71):** `deploy/apps/otel-collector.yaml` inlines its Helm values instead of sourcing them from a local `deploy/observability/otel-collector/values.yaml` per convention (Application object stays in `deploy/apps/`, consistent with every other category — `sealed-secrets`, `duckdns-updater`, `hello` all keep only local *manifests*, not the Application pointer, in their category folder). Out of scope here; `cert-manager.yaml` has the same gap.

## Risks / Trade-offs

- [Collector unreachable or misconfigured endpoint] → SDK's internal error handler logs export failures; `PeriodicReader` failures don't crash `hello` or block its HTTP responses (asynchronous, best-effort export)
- [New dependencies on a `scratch`-based image] → `otel`, `sdk/metric`, `otlpmetrichttp`, and `otelhttp` are all pure Go with no cgo, so static compilation for `scratch` is unaffected
- [ConfigMap duplicated per-service later] → accepted for now (only one consumer); extraction to a shared component deferred until a second service needs it

## Open Questions

None outstanding — wire protocol, metric surface, config delivery, resource attributes, code location, and test strategy were all resolved during design review.
