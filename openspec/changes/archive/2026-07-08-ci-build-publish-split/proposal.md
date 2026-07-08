## Why

`build-and-release` (app APK) and `build-push-hello` (Docker image) only run on `push` to `main`, so a PR's required checks (`test`, `test-hello`) never actually compile the Flutter/Android build or the Docker image. A PR can show all-green and still break `main` on merge — which already happened: an `ota_update` dependency required Android core library desugaring, and that only surfaced in `flutter build apk --release` on the push-triggered job, after the PR had merged. Splitting each service's pipeline into a build-validation job (runs on PR and push) and a publish job (push-only, depends on the build job) closes that gap for both services.

## What Changes

- Split `build-and-release` into `build-universal` (compiles the release APK, runs on PR and push, gated on `needs.filter.outputs.app == 'true'`) and `release-universal` (needs `build-universal`, downloads its APK artifact instead of rebuilding, creates the GitHub Release — push-only).
- Split `build-push-hello` into `build-hello` (`docker build` with `push: false`, runs on PR and push, gated on `needs.filter.outputs.hello == 'true'`) and `push-hello` (needs `build-hello`, `docker build` with `push: true` — push-only). `deploy-hello`'s `needs:` moves from `build-push-hello` to `push-hello`.
- `build-universal`/`build-hello` run in parallel with `test`/`test-hello`/`lint-deploy` (fail-fast PR signal); `release-universal`/`push-hello` still gate on all three of their respective build/test/lint-deploy jobs succeeding before publishing.
- `build-universal` computes `sha`/`timestamp` once and exposes them as job outputs; `release-universal` consumes them instead of recomputing, keeping the APK's embedded Build Tag in sync with the Release's `tag_name`.
- `build-hello` computes `sha` once and exposes it as a job output; `push-hello` and `deploy-hello` consume it instead of recomputing.
- Both `build-universal` and `build-hello` always upload their build artifact, even on PR runs, so a PR's build can be downloaded and tested before merge.
- `build-hello`/`push-hello` add `cache-from`/`cache-to: type=gha` to `docker/build-push-action` so `push-hello` reuses `build-hello`'s layers instead of a cold rebuild.
- `build-universal`/`test` add a `~/.pub-cache` cache (keyed on `app/pubspec.lock`) — pre-existing gap (only Gradle was cached), now worth closing since these jobs run at PR frequency instead of just on push.
- Add `build-universal` and `build-hello` to `main`'s branch ruleset `required_status_checks` (ruleset id 16254768), alongside the existing `test`/`test-hello`, so a broken compile blocks merge instead of only being visible after it.

## Capabilities

### New Capabilities
(none)

### Modified Capabilities
- `app-build-pipeline`: the build (compile) and publish (release) stages become separate jobs with separate trigger conditions; the build stage now also runs on PRs and is a required status check; Build Tag/timestamp computation moves to the build job and is passed to the publish job via outputs.
- `hello-ci-pipeline`: the build (compile) and publish (push to GHCR) stages become separate jobs with separate trigger conditions; the build stage now also runs on PRs and is a required status check; SHA computation moves to the build job and is passed downstream via outputs.

## Impact

- `.github/workflows/ci.yml`: job graph restructuring for both the app and hello pipelines (see above); no changes to `filter`, `lint-deploy`, or the internals of `test`/`test-hello` beyond adding the pub-cache step to `test`.
- GitHub repository ruleset (id 16254768) on `main`: `required_status_checks` gains `build-universal` and `build-hello`.
- No application code changes. No change to APK signing (still debug-signed in CI, unaffected by this split).
