## 1. Sealed Secrets controller installed as an Infra component

- [x] 1.1 `deploy/infra/sealed-secrets/` contains vendored raw controller manifests, targeting the `sealed-secrets` namespace
- [x] 1.2 `deploy/apps/sealed-secrets.yaml` Application syncs those manifests at `sync-wave: "0"`
- [x] 1.3 After sync, the controller pod in `sealed-secrets` namespace reports healthy — confirmed via `kubectl get application sealed-secrets -n argocd`
- [x] 1.4 No controller resource is placed in the `services` namespace

## 2. Controller private key is backed up off-cluster

- [x] 2.1 Following `docs/runbooks/sealed-secrets-key-backup.md`, export the controller's active key
- [x] 2.2 Encrypt the export locally with `age`; verify the plaintext export is deleted afterward
- [x] 2.3 Encrypted backup emailed to self (Gmail); verify it can be located and decrypted

## 3. DuckDNS token sealed and committed

- [x] 3.1 Fetch the controller's public cert via `kubeseal --fetch-cert`
- [x] 3.2 Seal the DuckDNS token with `strict` scope (no `--scope` flag) targeting the `duckdns-updater` namespace
- [x] 3.3 Commit the resulting `SealedSecret` under `deploy/infra/duckdns-updater/`
- [x] 3.4 After sync, confirm the controller decrypts it into a plain `Secret` in `duckdns-updater` — confirmed via `kubectl get secret duckdns-token -n duckdns-updater`

## 4. CronJob keeps xdezex.duckdns.org current

- [x] 4.1 `deploy/infra/duckdns-updater/` contains a `CronJob` (stock `curl`-capable image) on a 5-minute schedule
- [x] 4.2 The CronJob's request omits the `ip` query parameter and uses the token from the decrypted Secret
- [x] 4.3 `deploy/apps/duckdns-updater.yaml` Application syncs at `sync-wave: "1"`
- [x] 4.4 After the next scheduled run, `xdezex.duckdns.org` resolves to the current home IP — confirmed: both scheduled runs logged `OK`, and `nslookup xdezex.duckdns.org` matches the current public IP

## 5. Repo hygiene

- [x] 5.1 Rename the CI `infra` job-output filter to `deploy` in `.github/workflows/ci.yml`
- [x] 5.2 Rename `staged_infra` in `.githooks/pre-commit` — renamed to `staged_lint` instead of `staged_deploy` as originally planned, since `staged_deploy` already existed as a distinct, narrower-scoped variable; reusing that name would have silently collided. Also added `deploy/infra/sealed-secrets` and `deploy/infra/duckdns-updater` to the hook's kustomize/kubeconform build loop, which only covered `deploy/bootstrap` and `deploy/services/hello` before this change — without it, the new manifests would never be validated on commit.
- [x] 5.3 Confirm `docs/adr/0002-sealed-secrets.md`'s backup line points at the new runbook (already updated during design)
- [x] 5.4 Confirm `CONTEXT.md`'s "Infra component" entry and `docs/adr/0005-per-component-infra-namespaces.md` are present (already added during design)
