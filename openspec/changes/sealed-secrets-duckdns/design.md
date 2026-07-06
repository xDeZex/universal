## Context

Phase 0's remaining blocker for a real external secret: the DuckDNS updater needs a token, and this is a public repo, so nothing can be committed in plaintext (ADR 0002). No component in the cluster today can decrypt a committed secret. This change installs the Sealed Secrets controller as the first "Infra component" — a new category of thing this repo deploys, distinct from the backend Services in `deploy/services/` (ADR 0004's shared `services` namespace does not apply to it) — and uses it for its first real consumer, the DuckDNS updater.

## Goals / Non-Goals

**Goals:**
- Sealed Secrets controller running and able to decrypt a committed `SealedSecret`
- DuckDNS token never committed in plaintext
- `xdezex.duckdns.org` kept current automatically, no hand intervention
- Controller's private key recoverable after a cluster rebuild, without relying on any single cloud provider's storage being trustworthy on its own

**Non-Goals:**
- General secret-management tooling beyond this one token (no per-Service secret conventions yet — revisit when a Service needs one)
- Helm-based installation (raw manifests only, matching how ArgoCD itself was bootstrapped — see Decisions)
- TLS/cert-manager (issue #13, separate)

## Decisions

**`deploy/infra/` as a new top-level directory, sibling to `deploy/services/`.**
Sealed Secrets and the DuckDNS updater are not backend Services (per `CONTEXT.md`'s definition: "an independently deployable Go backend program... The app is not a Service; it is the client"). Filing them under `deploy/services/` would stretch that term past what it means. New term "Infra component" covers both, defined in `CONTEXT.md`.

**Per-component namespaces, not a shared `infra` namespace (ADR 0005).**
ADR 0004 shares one `services` namespace across backend Services because per-Service isolation doesn't pay for itself on a single-node, single-operator cluster. That reasoning doesn't automatically transfer here: Sealed Secrets' RBAC can decrypt any `SealedSecret` in the namespaces it's scoped to watch, so keeping it namespace-isolated bounds that blast radius for free (upstream's own manifests default to a dedicated namespace anyway). `sealed-secrets` and `duckdns-updater` each get their own namespace.

**Raw vendored manifests, not ArgoCD's Helm source support.**
ArgoCD supports installing Helm charts natively (`spec.source.helm`), but this repo has zero precedent for that pattern — `argocd-install.yaml` itself is a checked-in raw manifest. Introducing Helm-as-a-source for one component adds a second installation style to reason about for marginal benefit, given Sealed Secrets' manifest set is small and low-churn.

**CI filter rename: `infra` → `deploy`.**
`.github/workflows/ci.yml` already used a job-output filter named `infra` to mean "anything under `deploy/**`" (`.githooks/pre-commit`'s `staged_infra` variable, same meaning). Introducing `deploy/infra/` as a subdirectory would leave the same word meaning two different scopes in adjacent files. Renamed the CI/hook usage to `deploy` (its actual meaning) rather than inventing a different name for the new directory.

**SealedSecret scope: `strict`.**
Sealed Secrets defaults to `strict` (decrypts only into the exact namespace + secret name it was sealed for). No scenario here needs the token portable to a different namespace or secret name, and `strict` is free (no `--scope` flag needed). Consistent with ADR 0005's blast-radius reasoning.

**Sync-waves: `sealed-secrets` at `0`, `duckdns-updater` at `1`.**
The `SealedSecret` CRD only exists once the controller has synced. Without explicit ordering, ArgoCD could attempt to apply `duckdns-updater`'s `SealedSecret` before the CRD is registered, failing the first sync. Everything else in the repo (hello, bootstrap) is unannotated and defaults to wave `0`; nothing existing depends on ordering relative to these two, so this doesn't disturb prior behavior.

**DuckDNS CronJob: stock `curl` image, 5-minute schedule, no explicit `ip` param.**
Omitting DuckDNS's `ip` query parameter lets it auto-detect the caller's public IP from the request itself — correct here since the CronJob runs from inside the same LAN/NAT as the router. Avoids writing any IP-detection logic. 5 minutes matches DuckDNS's own recommended refresh cadence. A stock image means no Dockerfile, no CI build, no image to maintain for what is fundamentally a config-only task — consistent with installing Sealed Secrets itself as an off-the-shelf component rather than hand-building one.

**Key backup: `age`-encrypt, then store anywhere (Gmail, chosen).**
The controller's private key is the one piece of state that lives only in the cluster (ADR 0002's caveat). The security boundary is the encryption, not the storage location — an `age`-encrypted blob is exactly as safe in a Gmail attachment as in any other cloud storage, since neither Gmail nor Dropbox is a zero-knowledge store. Documented as a runbook (`docs/runbooks/sealed-secrets-key-backup.md`), a new doc category alongside `docs/adr/` for operational procedures rather than architectural decisions.

## Risks / Trade-offs

- **[Risk]** Per-component namespaces mean slightly more manifest boilerplate (a `Namespace` resource per component) than one shared `infra` namespace. → **Mitigation:** accepted per ADR 0005; cost is fixed and small, the isolation benefit compounds if more privileged Infra components are added later.
- **[Risk]** `age` key management for the backup lives outside git and outside this repo's tooling — if the `age` identity itself is lost, the backup is unrecoverable. → **Mitigation:** out of scope for this change; the runbook assumes the `age` identity is managed the same way as any other personal credential. Noted as a gap, not solved here.
- **[Risk]** CronJob failures (e.g. DuckDNS unreachable, token not yet decrypted) are silent unless someone checks `kubectl get cronjob`/logs — no alerting exists yet. → **Mitigation:** acceptable for Phase 0; Phase 1 (observability) is where alerting on job failures belongs.

## Migration Plan

1. Add `deploy/infra/sealed-secrets/` manifests + `deploy/apps/sealed-secrets.yaml` (wave `0`), sync, confirm controller healthy.
2. Run the key backup runbook once the controller has generated its first keypair.
3. Fetch the controller's public cert with `kubeseal --fetch-cert`, seal the DuckDNS token (`strict` scope), commit the SealedSecret under `deploy/infra/duckdns-updater/`.
4. Add the CronJob manifest + `deploy/apps/duckdns-updater.yaml` (wave `1`), sync.
5. Rename the CI filter and pre-commit variable (`infra` → `deploy`).
6. Confirm `xdezex.duckdns.org` resolves to the current home IP after the next scheduled run.

Rollback: delete the two new `deploy/apps/` Applications; ArgoCD prunes the associated resources. No effect on `hello` or any existing Service.

## Open Questions

None outstanding — all resolved during design discussion (see `CONTEXT.md`'s "Infra component" entry and ADR 0005).
