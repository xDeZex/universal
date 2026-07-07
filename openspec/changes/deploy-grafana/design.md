## Context

Prometheus (#62) is deployed and receiving hello's metrics via otel-collector's `prometheusremotewrite` exporter. `docs/adr/0008-observability-namespace.md` already fixes Grafana's namespace (`observability`, shared with the rest of the stack). Nothing yet fixes Grafana's chart, exposure, or credential handling — this design covers those, arrived at through `/opsx:explore` and `/grill-with-docs` sessions before this proposal.

`hello`'s Ingress (`deploy/services/hello/ingress.yaml`) already establishes the pattern for public exposure on this cluster: host `xdezex.duckdns.org`, TLS via cert-manager's `letsencrypt-prod` issuer, secret shared across Ingresses on the host per ADR-0007. Nothing on this cluster has been exposed as an *admin/dashboard* tool publicly before — ArgoCD's own UI is reachable only via `kubectl port-forward`, with no Ingress at all. Grafana breaks that precedent deliberately: unlike ArgoCD, there's value in glancing at dashboards without an SSH session, and doing so safely just requires real auth instead of network-obscurity.

## Goals / Non-Goals

**Goals:**
- Grafana running healthy in `observability`, reachable at `https://xdezex.duckdns.org/grafana` with a real login.
- A Prometheus datasource available in Grafana, so #65's first dashboard has something to query against.
- Auth locked down appropriately for a public instance: no anonymous access, no self-signup, real (not default) admin password.

**Non-Goals:**
- Any actual dashboards or alerts — that's #65.
- Dashboard/user persistence — deferred until #65 makes dashboards code (provisioned via ConfigMap), at which point Grafana's own SQLite state stops being something worth protecting.
- A Loki datasource — that's #66; this change only wires Prometheus.
- Multi-user setup beyond the single `admin` account — single-operator cluster, no need for org/team structure yet.

## Decisions

- **Chart: `grafana/grafana` (vendor's own repo), not a third-party repackaging.** Matches the established pattern — Prometheus sources from `prometheus-community/prometheus`, otel-collector from `open-telemetry/opentelemetry-helm-charts`. Both are the maintaining project's own chart, not e.g. a Bitnami repackaging.
  - *Alternative considered*: `bitnami/grafana` — rejected for consistency; no functional reason to deviate from the "source from the vendor" convention this repo has kept everywhere else.

- **Multi-source Application for the admin-credential SealedSecret**, unlike Prometheus/otel-collector's single-source form. `grafana.yaml`'s `sources` list combines the `grafana/grafana` chart with a second entry: a local git path (`deploy/observability-config/grafana-credentials/` or similar) holding just the SealedSecret. This is a new pattern for this repo — everything else with a local path (`hello`, `duckdns-updater`) either has no remote chart at all, or (`prometheus`, `otel-collector`) has no local manifests to bundle.
  - *Alternative considered*: fold the SealedSecret into the same file/Application as the datasource ConfigMap (e.g. rename to `grafana-config`) — rejected. The two have unrelated lifecycles (the datasource changes when Loki joins in #66; the secret doesn't) and a grab-bag name invites scope creep.
  - *Alternative considered*: a third, fully separate `grafana-credentials` Application, mirroring `observability-storage`'s granularity — rejected in favor of multi-source specifically because the secret is a **hard dependency** at Grafana pod startup (`admin.existingSecret`), unlike the datasource, which Grafana's sidecar discovers dynamically after the fact and tolerates arriving late. Bundling the hard dependency into the same Application as the chart lets ArgoCD sync both together; the datasource, with no startup-ordering requirement, is fine staying independent.

- **Exposure: chart-native `ingress` values, not a hand-authored Ingress manifest.** Both `prometheus.yaml` and `otel-collector.yaml` configure everything chart-specific inline via `helm.values`, with no local git path at all. Since Grafana has no sibling directory the way `hello` does (`deploy/services/hello/ingress.yaml` sits next to its Deployment), the two real options were the chart's built-in `ingress:` block or promoting the Ingress to its own Observability config Application. Chart-native keeps one Application responsible for the component and its exposure, consistent with how Prometheus's PVC/resources are inline rather than split out.
  - *Alternative considered*: standalone Ingress manifest as its own Observability config item — rejected as unnecessary ceremony for something the chart already supports natively.

- **Reuse the shared host TLS secret (`xdezex-duckdns-org-tls`), not a new certificate.** ADR-0007 exists precisely so a second Ingress on the same host doesn't trigger a duplicate ACME order. No new DNS record or router change is needed either — both already exist for `hello`.

- **Subpath serving via `server.root_url` + `serve_from_sub_path: true`.** Unlike `hello`, which returns bare JSON and is path-agnostic, Grafana generates its own links/redirects/asset URLs and needs to know it's served under `/grafana` rather than the domain root, or navigation breaks.

- **Auth locked down explicitly, not left to chart defaults.** `auth.anonymous.enabled: false` and `users.allow_sign_up: false` are set outright rather than trusted to whatever the chart or upstream Grafana currently defaults to — for a public instance, inheriting a safe default by omission isn't the same as deciding it.
  - *Alternative considered*: anonymous viewer access, for glancing at a dashboard without logging in — rejected; decided to keep the instance fully locked down rather than carve out a read-only exception.

- **Admin password via SealedSecret; username stays plain.** The chart splits these — `adminUser` is a non-sensitive plain value (`admin`), while only the password needs `admin.existingSecret`. The SealedSecret follows the same one-key shape as `duckdns-token`.

- **No persistence (`persistence.enabled: false`).** With dashboards intended to become code in #65, protecting Grafana's own SQLite state today isn't worth a PVC — anything not yet committed is disposable. This is a deliberate asymmetry with Prometheus, which does get a `Retain`-policy PVC (`observability-retain`) for its TSDB: Prometheus's data is the actual metrics history worth protecting; Grafana's local state, pre-#65, is not.

- **Datasource as its own Observability config item** (`deploy/observability-config/grafana-datasource/` + `deploy/apps/grafana-datasource.yaml`), mirroring `observability-storage`'s precedent, discovered via the chart's `sidecar.datasources` rather than baked into `grafana.yaml`'s own values. Keeps datasource wiring reviewable and extendable independent of the Grafana component itself — relevant the moment Loki (#66) adds a second datasource.

- **Sync-wave `"2"` for both `grafana.yaml` and `grafana-datasource.yaml`; no resource-level ordering for the bundled secret.** Grafana sits on top of the existing wave-0 (`observability-storage`, `otel-collector`) / wave-1 (`prometheus`) stack as a pure consumer. The one place ordering could theoretically matter — the SealedSecret source resolving after the Helm chart source on first sync — is left to `selfHeal` (already `automated: {prune: true, selfHeal: true}` on every existing Application) rather than solved with per-resource sync-wave annotations, since a single-node personal cluster tolerates a transient first-sync `CrashLoopBackOff` that self-heals within a minute.

- **Resources: `100m/128Mi` request, `500m/256Mi` limit** — matching otel-collector's sizing rather than Prometheus's. Prometheus does the heavy lifting (TSDB writes/compaction); Grafana here is a UI shell over one datasource, one admin user, no persistence.

## Risks / Trade-offs

- **[Risk]** Public exposure of an admin/dashboard tool is new territory for this cluster — a mistake in the auth-lockdown values is now internet-facing, not LAN-only. → **[Mitigation]** `auth.anonymous.enabled` and `users.allow_sign_up` are explicit values (not defaults), verified post-deploy as an explicit task; real SealedSecret password, no default credentials.
- **[Risk]** Multi-source Applications are unproven in this repo — first use of the `sources` (plural) form. → **[Mitigation]** The failure mode is a transient sync ordering hiccup, self-healed automatically; verified post-deploy by confirming the Grafana pod reaches `Running`/`Ready`.
- **[Risk]** No persistence means any dashboard built by hand before #65 lands is lost on pod restart. → **[Mitigation]** Accepted and deliberate — #65 is expected to define dashboards as code shortly after this change, making hand-built dashboards a bridge, not a destination.
- **[Risk]** Subpath serving (`serve_from_sub_path`) is a common source of broken asset/redirect URLs if misconfigured. → **[Mitigation]** Verify post-deploy by loading `https://xdezex.duckdns.org/grafana` in a browser and confirming login, navigation, and dashboard panels all resolve under `/grafana`, not the domain root.

## Migration Plan

1. Add `deploy/observability-config/grafana-datasource/` (ConfigMap + `kustomization.yaml`) and `deploy/apps/grafana-datasource.yaml` (sync-wave `"2"`), datasource pointed at `http://prometheus-server.observability.svc.cluster.local`.
2. Add the admin-password SealedSecret under a local path (e.g. `deploy/observability-config/grafana-credentials/`).
3. Add `deploy/apps/grafana.yaml` (sync-wave `"2"`), multi-source (`grafana/grafana` chart + the SealedSecret's local path), with: `ingress` for `xdezex.duckdns.org/grafana` reusing `xdezex-duckdns-org-tls`; `server.root_url`/`serve_from_sub_path`; `auth.anonymous.enabled: false`; `users.allow_sign_up: false`; `adminUser: admin`; `admin.existingSecret` referencing the sealed password; `sidecar.datasources.enabled: true`; `persistence.enabled: false`; resources per above.
4. Commit and let ArgoCD sync — no manual `kubectl apply`, per `deploy/CLAUDE.md`.
5. Verify, in order: `grafana` and `grafana-datasource` Applications both `Synced`/`Healthy` → Grafana pod `Running`/`Ready` → `https://xdezex.duckdns.org/grafana` loads the login page over valid TLS → admin login succeeds with the sealed password → anonymous/unauthenticated access is refused → the Prometheus datasource is present and a test query against a `hello`-emitted metric returns data.

Rollback is low-risk: deleting the `grafana` and `grafana-datasource` Applications removes everything this change adds; nothing here touches `prometheus.yaml` or `otel-collector.yaml`, and there's no PVC to orphan.

## Open Questions — resolved during implementation

- **Chart version**: at implementation time, `grafana/grafana` (`grafana.github.io/helm-charts`) was found to have migrated to `grafana-community/helm-charts` (`grafana-community.github.io/helm-charts`) after 2026-01-30; the old repo's `gh-pages` index is frozen at chart `10.5.15` (app `12.3.1`) with no further releases. Confirmed with the user and pinned to the new repo, chart `12.7.2` (app `13.1.0`) — still Grafana's own maintained repo, just relocated, so the original "vendor's own repo" decision still holds.
- **SealedSecret local path**: `deploy/observability-config/grafana-credentials/sealedsecret.yaml`.
- **Admin credential shape** (not anticipated as an open question, but resolved during implementation): the chart's `admin.existingSecret` sources *both* `GF_SECURITY_ADMIN_USER` and `GF_SECURITY_ADMIN_PASSWORD` from the same secret (via `admin.userKey`/`admin.passwordKey`, defaulting to keys `admin-user`/`admin-password`) — there's no plain-value path for the username once `existingSecret` is set. The SealedSecret holds both keys (`admin-user: admin`, `admin-password: <generated>`) rather than only the password as originally described; `adminUser` is not set in Helm values.
