# universal-ci-pipeline Specification

## Purpose
Define the dedicated CI workflow for building, validating, and releasing the Universal APK after the `app/` → `universal/` rename and workflow split.

## Requirements
### Requirement: Universal build only triggers for `universal/**` changes

`.github/workflows/ci-universal.yml` SHALL use a native `paths` trigger (`on.push.paths` / `on.pull_request.paths`) scoped to `universal/**` and the workflow file itself, rather than a shared `dorny/paths-filter` job. `test-universal`, `build-universal`, and `release-universal` all run unconditionally within this file, since the file-level trigger already gates the whole workflow — a push or pull request that doesn't touch `universal/**` (or `ci-universal.yml`) SHALL NOT start this workflow at all.

#### Scenario: Happy path — Universal change on main triggers a build and a release

- **WHEN** a commit touching `universal/**` is pushed to `main` and `test-universal` succeeds
- **THEN** the `build-universal` job runs, and once it and `test-universal` have both succeeded, `release-universal` runs and publishes a GitHub Release with the signed APK

#### Scenario: Happy path — Universal change on a PR triggers a build but not a release

- **WHEN** a commit touching `universal/**` is pushed on a pull request branch
- **THEN** the `build-universal` job runs and uploads the built APK as a workflow artifact; `release-universal` does not run, since it only runs on `push` events

#### Scenario: Error/rejection — unrelated push does not trigger the workflow

- **WHEN** a commit is pushed to `main` that only touches `services/**` or `deploy/**`
- **THEN** `ci-universal.yml` does not run at all (the file-level `paths` trigger excludes it), so `test-universal`, `build-universal`, and `release-universal` never execute and no GitHub Release is published

#### Scenario: Contract — editing the workflow file itself re-triggers it

- **WHEN** a commit changes only `.github/workflows/ci-universal.yml` (e.g. a job step is edited)
- **THEN** the workflow's `paths` trigger includes its own filename, so the workflow runs and validates the edit

---

### Requirement: Universal build publishes a SHA-256 checksum alongside the APK

When CI publishes a Universal release, it SHALL compute a SHA-256 checksum of the signed release APK and publish it as a second asset on the same GitHub Release, named `<apk-name>.sha256`.

#### Scenario: Happy path — checksum published with the APK

- **WHEN** the `release-universal` job downloads the `Universal.apk` artifact produced by `build-universal`
- **THEN** CI computes its SHA-256 checksum, writes it to `Universal.apk.sha256`, and the GitHub Release includes both `Universal.apk` and `Universal.apk.sha256` as assets

#### Scenario: Error/rejection — checksum step failure blocks the release

- **WHEN** the checksum computation step fails (e.g. the downloaded APK artifact is missing or corrupt)
- **THEN** the workflow fails before the release-creation step runs, and no GitHub Release is published

#### Scenario: Contract — checksum matches the published APK

- **WHEN** a user downloads `Universal.apk` and `Universal.apk.sha256` from the same Release
- **THEN** running `sha256sum -c Universal.apk.sha256` against the downloaded APK reports success

---

### Requirement: Universal build embeds a Build Tag for update checking

`build-universal` SHALL compute a commit SHA and timestamp once, expose them as job outputs, and pass the resulting tag string into the `flutter build apk` step via `--dart-define`, embedding it as a compile-time constant Universal can read as its own Build Tag. `release-universal` SHALL consume the same job outputs — rather than recomputing its own SHA/timestamp — when naming the GitHub Release `tag_name`, so the two values are always identical.

#### Scenario: Happy path — built APK carries the release's own tag

- **WHEN** `build-universal` computes its `sha`/`timestamp` outputs and builds the APK
- **THEN** the APK is built with `--dart-define` set to the tag derived from those outputs, and `release-universal` uses the same outputs to compute the GitHub Release `tag_name`, so Universal's own Build Tag equals the tag of the release it ships in

#### Scenario: Error/rejection — missing outputs fails the build

- **WHEN** `build-universal`'s commit-info step fails to produce `sha`/`timestamp` outputs
- **THEN** the workflow fails before the `flutter build apk` step runs, and no APK artifact or GitHub Release is produced

#### Scenario: Contract — dart-define key matches what Universal reads

- **WHEN** CI passes the Build Tag via `--dart-define`
- **THEN** it uses the same key name that `UpdateService` reads via `String.fromEnvironment` in `universal/`

---

### Requirement: Universal build validation runs on pull requests and is a required status check

CI SHALL run `build-universal` on pull requests touching `universal/**`, in parallel with `test-universal` rather than staged behind it, and SHALL upload the resulting APK as a downloadable workflow artifact regardless of whether the triggering event is a `pull_request` or a `push`. `build-universal` SHALL be a required status check on `main`'s branch ruleset. `release-universal` SHALL reuse the exact APK artifact `build-universal` produced (via `actions/download-artifact`) rather than rebuilding it. Validation of `deploy/` manifests (`lint-deploy`, in the independent `deploy-manifest-pipeline`) SHALL NOT gate any job in this workflow — the two are unrelated, independently-versioned artifacts.

#### Scenario: Happy path — PR build succeeds and is downloadable

- **WHEN** a pull request touching `universal/**` is opened and the Flutter/Gradle build succeeds
- **THEN** the `build-universal` check passes, and the built APK is available as a downloadable workflow artifact on that run, without any GitHub Release being created

#### Scenario: Error/rejection — a compile failure blocks merge

- **WHEN** a pull request touching `universal/**` introduces a change that fails to compile (e.g. a dependency requiring Android core library desugaring that isn't enabled)
- **THEN** the `build-universal` job fails, and `main`'s branch ruleset blocks the pull request from merging

#### Scenario: Contract — the published APK is the same binary that was validated

- **WHEN** `release-universal` runs after a successful `build-universal` on push to `main`
- **THEN** it downloads and publishes the identical APK artifact `build-universal` produced, rather than invoking `flutter build apk` a second time
