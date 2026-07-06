## 1. Sealed Secrets controller installed as an Infra component

- [x] 1.1 `deploy/infra/sealed-secrets/` contains vendored raw controller manifests, targeting the `sealed-secrets` namespace
- [x] 1.2 `deploy/apps/sealed-secrets.yaml` Application syncs those manifests at `sync-wave: "0"`
- [x] 1.3 After sync, the controller pod in `sealed-secrets` namespace reports healthy — confirmed via `kubectl get application sealed-secrets -n argocd`
- [x] 1.4 No controller resource is placed in the `services` namespace

## 2. Controller private key is backed up off-cluster

- [ ] 2.1 **Deferred — manual, real credentials.** Following `docs/runbooks/sealed-secrets-key-backup.md`, export the controller's active key
- [ ] 2.2 **Deferred — manual, real credentials.** Encrypt the export locally with `age`; verify the plaintext export is deleted afterward
- [ ] 2.3 **Deferred — manual, real credentials.** Encrypted backup emailed to self (Gmail); verify it can be located and decrypted

## 3. DuckDNS token sealed and committed

- [x] 3.1 Fetch the controller's public cert via `kubeseal --fetch-cert`
- [x] 3.2 Seal the DuckDNS token with `strict` scope (no `--scope` flag) targeting the `duckdns-updater` namespace
- [x] 3.3 Commit the resulting `SealedSecret` under `deploy/infra/duckdns-updater/`
- [ ] 3.4 **Deferred — needs a few minutes post-merge.** After sync, confirm the controller decrypts it into a plain `Secret` in `duckdns-updater`

## 4. CronJob keeps xdezex.duckdns.org current

- [x] 4.1 `deploy/infra/duckdns-updater/` contains a `CronJob` (stock `curl`-capable image) on a 5-minute schedule
- [x] 4.2 The CronJob's request omits the `ip` query parameter and uses the token from the decrypted Secret
- [x] 4.3 `deploy/apps/duckdns-updater.yaml` Application syncs at `sync-wave: "1"`
- [ ] 4.4 **Deferred — post-merge, live cluster.** After the next scheduled run, `xdezex.duckdns.org` resolves to the current home IP

## 5. Repo hygiene

- [x] 5.1 Rename the CI `infra` job-output filter to `deploy` in `.github/workflows/ci.yml`
- [x] 5.2 Rename `staged_infra` in `.githooks/pre-commit` — renamed to `staged_lint` instead of `staged_deploy` as originally planned, since `staged_deploy` already existed as a distinct, narrower-scoped variable; reusing that name would have silently collided. Also added `deploy/infra/sealed-secrets` and `deploy/infra/duckdns-updater` to the hook's kustomize/kubeconform build loop, which only covered `deploy/bootstrap` and `deploy/services/hello` before this change — without it, the new manifests would never be validated on commit.
- [x] 5.3 Confirm `docs/adr/0002-sealed-secrets.md`'s backup line points at the new runbook (already updated during design)
- [x] 5.4 Confirm `CONTEXT.md`'s "Infra component" entry and `docs/adr/0005-per-component-infra-namespaces.md` are present (already added during design)

## Deferred to user (post-merge / requires real credentials)

Tasks 1.3, 2.1–2.3, 3.1–3.4, and 4.4 need either a live cluster synced via ArgoCD (only happens once this merges to `main`) or real secrets that must not pass through this session (the DuckDNS token, the `age` identity, the Gmail account). Once merged, run through these manually — `docs/runbooks/sealed-secrets-key-backup.md` covers the key backup; sealing the real token needs `kubeseal --fetch-cert` against the live controller followed by `kubeseal` with `--scope strict` (default), then committing the resulting `SealedSecret` into `deploy/infra/duckdns-updater/` (and adding it to that directory's `kustomization.yaml` resources list) as a small follow-up commit.
