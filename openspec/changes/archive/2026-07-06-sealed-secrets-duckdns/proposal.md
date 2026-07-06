## Why

Closes issue #12 (Phase 0). DuckDNS needs to keep `xdezex.duckdns.org` pointed at the home IP, which requires a token — but this repo is public, so the token can't be committed in plaintext. Nothing in the cluster today can decrypt a committed secret, so the DuckDNS updater is blocked until Sealed Secrets is installed first.

## What Changes

- Install the Bitnami Sealed Secrets controller as a new ArgoCD Application, using vendored raw manifests (consistent with how ArgoCD itself was bootstrapped), in its own `sealed-secrets` namespace
- Introduce `deploy/infra/` as a new top-level directory for cluster infrastructure components that are not backend Services, alongside the existing `deploy/services/`
- Rename the CI `infra` job-output filter (`.github/workflows/ci.yml`) and the pre-commit hook's `staged_infra` variable to `deploy`, removing the naming collision with the new `deploy/infra/` directory
- Seal the DuckDNS token with `kubeseal` (strict scope) and commit the resulting SealedSecret
- Add a CronJob (stock `curl` image, every 5 minutes, no explicit `ip` param) that hits DuckDNS's update endpoint to keep `xdezex.duckdns.org` current
- Order the two new Applications with ArgoCD sync-waves (`sealed-secrets` wave `0`, `duckdns-updater` wave `1`) so the SealedSecret CRD exists before it's used
- Add `docs/runbooks/sealed-secrets-key-backup.md` documenting the manual, off-git backup of the controller's private key (export → `age`-encrypt → email to self → delete local copies), and fix the stale "off-Pi" reference in `docs/adr/0002-sealed-secrets.md` to point at it
- Add ADR 0005 documenting that Infra components get per-component namespaces, deliberately deviating from ADR 0004's shared-namespace policy for Services

## Capabilities

### New Capabilities
- `sealed-secrets`: Sealed Secrets controller running in-cluster as an Infra component, able to decrypt SealedSecret resources committed to the public repo
- `duckdns-updater`: Scheduled job that keeps `xdezex.duckdns.org` pointed at the current home IP, using a token stored only as a SealedSecret

### Modified Capabilities
(none — no existing spec's requirements change; the CI filter rename is an implementation detail not covered by `hello-ci-pipeline`'s spec)

## Impact

- New directory `deploy/infra/` (`sealed-secrets/`, `duckdns-updater/`) and two new files in `deploy/apps/`
- `.github/workflows/ci.yml` and `.githooks/pre-commit`: rename `infra` → `deploy`
- `docs/adr/0002-sealed-secrets.md`: one-line fix (already applied during design discussion)
- New `docs/adr/0005-per-component-infra-namespaces.md` and `docs/runbooks/sealed-secrets-key-backup.md` (already written during design discussion)
- `CONTEXT.md`: new "Infra component" term (already added during design discussion)
- No changes to `services/hello` or existing ArgoCD Applications
