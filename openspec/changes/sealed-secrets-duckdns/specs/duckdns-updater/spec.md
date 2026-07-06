## ADDED Requirements

### Requirement: DuckDNS token is stored only as a SealedSecret

The DuckDNS update token SHALL be sealed with `kubeseal` using `strict` scope (no explicit `--scope` flag) and committed as a `SealedSecret` resource under `deploy/infra/duckdns-updater/`. No plaintext token SHALL appear anywhere in git.

#### Scenario: Happy path — sealed token decrypts into the running Secret

- **WHEN** the `duckdns-updater` Application is synced after the Sealed Secrets controller is healthy
- **THEN** the controller decrypts the committed `SealedSecret` into a plain `Secret` in the `duckdns-updater` namespace, usable by the CronJob

#### Scenario: Error/rejection — sealed value unusable outside its exact target

- **WHEN** the committed `SealedSecret` YAML is copied into a different namespace or given a different Secret name
- **THEN** the controller SHALL fail to decrypt it, since `strict` scope binds the sealed value to its exact original namespace and name

---

### Requirement: CronJob keeps xdezex.duckdns.org pointed at the current home IP

A Kubernetes `CronJob` (stock `curl`-capable image, no custom build) SHALL run every 5 minutes, calling DuckDNS's update endpoint for `xdezex.duckdns.org` with the token from the decrypted Secret, omitting the `ip` query parameter so DuckDNS auto-detects the caller's public IP. It SHALL be synced at `argocd.argoproj.io/sync-wave: "1"`, after the Sealed Secrets controller.

#### Scenario: Happy path — scheduled update succeeds

- **WHEN** the CronJob fires on schedule
- **THEN** it sends a request to DuckDNS's update endpoint for `xdezex.duckdns.org` using the sealed token, with no `ip` parameter in the URL

#### Scenario: Error/rejection — missing token

- **WHEN** the `SealedSecret` has not yet been decrypted into a running Secret (e.g. controller not yet healthy)
- **THEN** the CronJob's pod fails to start (missing secret mount/env) and Kubernetes retries on the next scheduled run, rather than silently sending a request with an empty token

#### Scenario: Contract — no IP resolution logic runs inside the job

- **WHEN** the CronJob's container starts
- **THEN** it performs a single HTTP request to DuckDNS with the `ip` parameter omitted, and contains no logic to independently determine the public IP
