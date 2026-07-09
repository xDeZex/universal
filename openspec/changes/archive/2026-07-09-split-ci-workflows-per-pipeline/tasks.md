## 1. Universal directory rename

- [x] 1.1 `app/` is renamed to `universal/` with no content changes; `flutter pub get`, `flutter analyze`, and `flutter test` all pass from within `universal/`
- [x] 1.2 Every reference to the `app/` path outside the directory itself (docs, scripts, `.gitignore` entries, etc.) is updated to `universal/`

## 2. CONTEXT.md vocabulary

- [x] 2.1 `CONTEXT.md` defines **Universal** and no longer contains "App release"/"App build" as anything other than aliases to avoid (already completed during exploration — verify it's carried onto this branch)

## 3. ci-universal.yml

- [x] 3.1 `.github/workflows/ci-universal.yml` exists, triggering only on `universal/**` and its own filename, for both `push` (to `main`) and `pull_request` (to `main`) events
- [x] 3.2 `test-universal` (renamed from `test`) runs Flutter tests and `flutter analyze` against `universal/`, with no `needs:`/`if:` filter-job gating (the file-level trigger already gates it)
- [x] 3.3 `build-universal` runs on both PR and push, uploads the built APK as a workflow artifact on every run, and exposes `sha`/`timestamp` job outputs consumed by the Build Tag `--dart-define` and by `release-universal`
- [x] 3.4 `release-universal` runs only on `push`, needs `[build-universal, test-universal]`, downloads (not rebuilds) the APK artifact, computes and publishes its SHA-256 checksum, and does not depend on `lint-deploy` or any job outside this file

## 4. ci-hello.yml

- [x] 4.1 `.github/workflows/ci-hello.yml` exists, triggering only on `services/hello/**`, `deploy/services/hello/**` (so a direct manifest edit — including `deploy-hello`'s own tag-bump commit — re-runs `validate-hello-manifests`), and its own filename, for both `push` (to `main`) and `pull_request` (to `main`) events
- [x] 4.2 `test-hello`, `build-hello`, and a new `validate-hello-manifests` job all run in parallel directly off the trigger, with no `needs:`/`if:` filter-job gating
- [x] 4.3 `validate-hello-manifests` runs `kustomize build deploy/services/hello | kubeconform` (reusing `./.github/actions/setup-kustomize`), scoped only to that directory, and fails independently of every other job in the file
- [x] 4.4 `push-hello` needs `[test-hello, build-hello]` only — no dependency on `lint-deploy` or `validate-hello-manifests` — and behaves identically otherwise (SHA/cache reuse from `build-hello`, `push: true`)
- [x] 4.5 `deploy-hello` needs `[push-hello, validate-hello-manifests]`, and only commits the `deploy/services/hello/kustomization.yaml` tag bump when both succeed

## 5. ci-deploy.yml

- [x] 5.1 `.github/workflows/ci-deploy.yml` exists, triggering on `deploy/**` excluding `deploy/services/hello/**`, plus `.yamllint.yml` and its own filename, for both `push` (to `main`) and `pull_request` (to `main`) events
- [x] 5.2 `lint-deploy` yamllints `deploy/`, `.yamllint.yml`, and `.github/`, then builds/validates only `deploy/bootstrap`, every directory under `deploy/infra/`, and every file under `deploy/apps/` — `deploy/services/hello` is no longer built or validated here
- [x] 5.3 A change touching only `deploy/services/hello/**` does not trigger `ci-deploy.yml`

## 6. Cutover and cleanup

- [x] 6.1 `.github/workflows/ci.yml` and the `dorny/paths-filter` `filter` job are deleted; no workflow file references `needs.filter.outputs.*` anywhere
- [x] 6.2 `main`'s branch ruleset `required_status_checks` is updated to reference `test-universal`/`build-universal` (renamed) and any other checks that changed name, and a test PR confirms the expected checks appear as required
- [x] 6.3 A PR touching both `universal/**` and `.github/workflows/**` in the same branch shows all three new workflows running and passing before merge
