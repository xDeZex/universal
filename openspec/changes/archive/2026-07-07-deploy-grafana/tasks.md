## 1. Admin-credential SealedSecret

- [x] 1.1 A SealedSecret manifest under a local path (`deploy/observability-config/grafana-credentials/sealedsecret.yaml`) encrypts a Secret holding the Grafana admin credentials. Two keys, not one (`admin-user`, `admin-password`) — the `grafana/grafana` chart's `admin.existingSecret` sources both `GF_SECURITY_ADMIN_USER` and `GF_SECURITY_ADMIN_PASSWORD` from the same secret via `admin.userKey`/`admin.passwordKey` (default `admin-user`/`admin-password`); there's no separate plain-value path for the username once `existingSecret` is set, unlike design.md's original assumption
- [x] 1.2 A `kustomization.yaml` alongside it lists the SealedSecret resource
- [x] 1.3 No plaintext password appears anywhere in the committed manifests — sealed via `kubeseal` on the `miniser` host (strict scope, no `--scope` flag), matching the `duckdns-token` precedent

## 2. Grafana deployment

- [x] 2.1 `deploy/apps/grafana.yaml` (new ArgoCD Application, sync-wave `"2"`) uses a multi-source `sources` list: the `grafana/grafana` Helm chart, plus the local git path from task 1, targeting the `observability` namespace. **Chart repo changed from design.md's assumption**: the chart migrated from `grafana.github.io/helm-charts` to `grafana-community.github.io/helm-charts` after 2026-01-30 (old repo's `gh-pages` index is frozen at 10.5.15/app 12.3.1 with no further releases); pinned to `12.7.2` (app 13.1.0) from the new repo — confirmed with the user before proceeding
- [x] 2.2 Helm values set `admin.existingSecret: grafana-admin-credentials` (both admin user and password sourced from it — see 1.1; no separate `adminUser` value)
- [x] 2.3 Helm values set `auth.anonymous.enabled: false` and `users.allow_sign_up: false` explicitly (under `grafana.ini`, since that's how the chart renders these ini sections)
- [x] 2.4 Helm values set `persistence.enabled: false`
- [x] 2.5 Helm values set `sidecar.datasources.enabled: true`
- [x] 2.6 Helm values set explicit `resources.requests`/`resources.limits` for CPU and memory (`100m`/`128Mi` request, `500m`/`256Mi` limit) for the main `grafana` container. **Post-review fix**: `sidecar.datasources.enabled: true` (task 2.5) adds a second container (`grafana-sc-datasources`) to the same pod; the chart's `.Values.sidecar.resources` is a separate, independently-defaulted-to-`{}` value not covered by the top-level `resources` block — added explicit `sidecar.resources` (`50m`/`50Mi` request, `100m`/`100Mi` limit) so the sidecar isn't left unbounded

## 3. Public ingress and subpath serving

- [x] 3.1 Helm values' chart-native `ingress` block defines a rule for host `xdezex.duckdns.org`, path `/grafana` (prefix), with the `cert-manager.io/cluster-issuer: letsencrypt-prod` annotation
- [x] 3.2 The Ingress's `tls` block reuses `secretName: xdezex-duckdns-org-tls` — no new Certificate or secret is created
- [x] 3.3 Helm values set `server.root_url: https://xdezex.duckdns.org/grafana` and `server.serve_from_sub_path: true` (under `grafana.ini.server`)

## 4. Prometheus datasource

- [x] 4.1 `deploy/observability-config/grafana-datasource/` contains a ConfigMap defining a Prometheus datasource, labeled `grafana_datasource: "1"` so Grafana's sidecar discovers it (matches the chart's default `sidecar.datasources.label`)
- [x] 4.2 The datasource's `url` is `http://prometheus-server.observability.svc.cluster.local`, matching otel-collector's existing `prometheusremotewrite` endpoint host
- [x] 4.3 A `kustomization.yaml` alongside it lists the ConfigMap resource
- [x] 4.4 `deploy/apps/grafana-datasource.yaml` (new ArgoCD Application, sync-wave `"2"`) sources `deploy/observability-config/grafana-datasource/` and targets the `observability` namespace

## 5. Post-deploy verification (requires the live sync — do last)

- [x] 5.1 After ArgoCD syncs, `ssh miniser` + `kubectl -n argocd wait --for=jsonpath='{.status.sync.status}'=Synced application/grafana` and `application/grafana-datasource` both succeed, followed by the equivalent `health.status=Healthy` wait — root app hadn't picked up the merge commit yet (last reconcile was against the prior commit); triggered `kubectl annotate application root argocd.argoproj.io/refresh=hard`, after which both Applications appeared and reported `Synced`/`Healthy`
- [x] 5.2 `kubectl -n observability get pods` shows the Grafana pod `Running` and `Ready`, with no PVC (persistence disabled); every container in the pod (`grafana` and `grafana-sc-datasources`) has non-empty `resources.requests`/`resources.limits` — confirmed `2/2 Running`, no PVC, both containers have explicit requests/limits matching the values set in task 2.6
- [x] 5.3 `https://xdezex.duckdns.org/grafana` loads over valid TLS and redirects to the login page, with all asset/redirect URLs staying under `/grafana` — confirmed valid LE cert, `302` to `/grafana/login?redirectTo=...`, login page `200` with relative asset URLs resolving under `/grafana/`
- [x] 5.4 An unauthenticated request to a dashboard/data endpoint is redirected to login, not served anonymously; the sign-up flow does not allow account creation — confirmed `401` on `/grafana/api/dashboards/home` and `/grafana/api/datasources`; `POST /grafana/api/user/signup` returns `401` with `"User signup is disabled"`
- [x] 5.5 Logging in as `admin` with the sealed password succeeds — confirmed via `/grafana/login` API using credentials decrypted from the live cluster Secret (never left the `miniser` shell); session cookie authenticates as `admin` with `isGrafanaAdmin: true`
- [x] 5.6 The Prometheus datasource is present in Grafana's datasource list and a test query against a `hello`-emitted metric returns data — datasource listed (`isDefault: true`, `readOnly: true`); queried `http_server_request_duration_seconds_count` through the datasource proxy, got a real result with `job="hello"`, `http_route="/"`, `http_response_status_code="200"`
