## 1. Split the app pipeline into `build-universal` and `release-universal`

- [x] 1.1 New `build-universal` job: `needs: filter`, `if: needs.filter.outputs.app == 'true'` (runs on both `pull_request` and `push`), contains the existing Java/Flutter/Gradle setup, Gradle cache, Android license acceptance, `flutter pub get`, the `Get commit info` step (`sha`/`timestamp`), and `flutter build apk --release --dart-define=BUILD_TAG=...` using those outputs
- [x] 1.2 `build-universal` declares `outputs: sha` and `outputs: timestamp` sourced from its `Get commit info` step
- [x] 1.3 `build-universal` renames the APK to `Universal.apk` and uploads it via `actions/upload-artifact` unconditionally (both PR and push runs)
- [x] 1.4 New `~/.pub-cache` cache step (`actions/cache@v4`, keyed on `hashFiles('app/pubspec.lock')`) added to `build-universal`, placed after `flutter pub get`'s dependencies are known but before it runs
- [x] 1.5 Same `~/.pub-cache` cache step added to the existing `test` job
- [x] 1.6 `release-universal` job: `needs: [build-universal, test, lint-deploy]`, `if: github.event_name == 'push' && needs.build-universal.result == 'success' && needs.test.result == 'success' && (needs.lint-deploy.result == 'success' || needs.lint-deploy.result == 'skipped')`
- [x] 1.7 `release-universal` downloads the `Universal-apk` artifact via `actions/download-artifact` instead of rebuilding
- [x] 1.8 `release-universal` computes the SHA-256 checksum of the downloaded APK, writes `Universal.apk.sha256`
- [x] 1.9 `release-universal` writes the release body and creates the GitHub Release using `sha`/`timestamp` consumed from `needs.build-universal.outputs`, not recomputed
- [x] 1.10 Old `build-and-release` job removed

## 2. Split the hello pipeline into `build-hello` and `push-hello`

- [x] 2.1 New `build-hello` job: `needs: [filter, test-hello, lint-deploy]` removed in favor of `needs: filter` only; `if: needs.filter.outputs.hello == 'true'` (runs on both `pull_request` and `push`); runs `docker/build-push-action` with `push: false`, `cache-from: type=gha`, `cache-to: type=gha,mode=max`
- [x] 2.2 `build-hello` computes the short SHA via a `Get short SHA` step and declares `outputs: sha`
- [x] 2.3 New `push-hello` job (renamed from `build-push-hello`): `needs: [build-hello, test-hello, lint-deploy]`, `if: github.event_name == 'push' && needs.build-hello.result == 'success' && needs.test-hello.result == 'success' && (needs.lint-deploy.result == 'success' || needs.lint-deploy.result == 'skipped')`
- [x] 2.4 `push-hello` runs `docker/build-push-action` with `push: true`, `cache-from: type=gha`, `cache-to: type=gha,mode=max`, tagging with `needs.build-hello.outputs.sha` instead of recomputing its own SHA
- [x] 2.5 `push-hello` declares `outputs: sha` (pass-through of `needs.build-hello.outputs.sha`)
- [x] 2.6 `deploy-hello`'s `needs:` updated from `build-push-hello` to `push-hello`, and its `SHA` env var sourced from `needs.push-hello.outputs.sha`
- [x] 2.7 Old `build-push-hello` job removed

## 3. Enforce build validation as a required check

- [x] 3.1 `main`'s GitHub ruleset (id `16254768`) `required_status_checks.required_status_checks` updated to include `build-universal` and `build-hello`, alongside the existing `test`/`test-hello` (same `integration_id`)

## 4. Documentation

- [x] 4.1 `CONTEXT.md` includes the "App release" term, distinguishing it from "Deploy commit" (already done during exploration — verify it's present on this branch)

## 5. Verification

- [x] 5.1 `.github/workflows/ci.yml` passes YAML validation (e.g. `yamllint` or a GitHub Actions workflow linter)
- [ ] 5.2 Open a PR touching only `app/**`: confirm `test` and `build-universal` both run, `build-universal`'s APK artifact is downloadable from the run, and `release-universal` does not run
- [ ] 5.3 Open a PR touching only `services/hello/**`: confirm `test-hello` and `build-hello` both run and `push-hello` does not run
- [ ] 5.4 Confirm both `build-universal` and `build-hello` show up as required checks on the PRs above (ruleset change from Task 3.1 took effect)
- [ ] 5.5 Merge an `app/**`-touching change to `main` and confirm: `release-universal` runs, downloads (not rebuilds) the APK, publishes a GitHub Release whose `tag_name` matches the Build Tag embedded in the APK, and the release includes a matching `.sha256` asset
- [ ] 5.6 Merge a `services/hello/**`-touching change to `main` and confirm: `push-hello` runs, pushes an image tagged with `build-hello`'s SHA output, and `deploy-hello` bumps `deploy/services/hello/kustomization.yaml` to the same SHA
- [ ] 5.7 Confirm via the Actions run timing/logs that `push-hello` reused `build-hello`'s cached layers rather than a cold rebuild
- [ ] 5.8 Confirm a push to `main` touching only `deploy/**` or docs leaves `build-universal`, `release-universal`, `build-hello`, and `push-hello` all skipped
