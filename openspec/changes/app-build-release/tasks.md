## 1. App build only triggers for `app/**` changes

- [ ] 1.1 `test` job's `if` condition changed to `needs.filter.outputs.app == 'true'` (drop the `|| github.event_name == 'push'` clause)
- [ ] 1.2 `build-and-release` job's `if` condition includes an explicit `needs.filter.outputs.app == 'true'` check, alongside its existing `needs.test.result == 'success'` check
- [ ] 1.3 Manually trace the updated `ci.yml` conditions against the PR-triggered ruleset checks (`test`, `test-hello`) to confirm required-status-check gating on `main` is unaffected

## 2. App build publishes a SHA-256 checksum alongside the APK

- [ ] 2.1 New step added after the "Rename APK" step that runs `sha256sum` against `Universal.apk` and writes the result to `Universal.apk.sha256`
- [ ] 2.2 `softprops/action-gh-release` step's `files` input includes both `app/build/app/outputs/flutter-apk/Universal.apk` and the new `.sha256` file

## 3. Documentation

- [ ] 3.1 `CONTEXT.md` includes the "App build" term, distinguishing it from "Deploy commit" (already done during exploration — verify it's present on this branch)

## 4. Verification

- [ ] 4.1 `.github/workflows/ci.yml` passes YAML validation (e.g. `yamllint` or a GitHub Actions workflow linter, if available)
- [ ] 4.2 Push a commit touching only `app/**` to a test branch/PR and confirm `test` runs; confirm on a simulated/manual review that `build-and-release`'s conditions would evaluate true after merge to `main`
- [ ] 4.3 Confirm via code review (no live push needed) that a commit touching only `services/**` or `deploy/**` would leave both `test` and `build-and-release` skipped
