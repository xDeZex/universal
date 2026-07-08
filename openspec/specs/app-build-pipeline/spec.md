# app-build-pipeline Specification

## Purpose
TBD - created by syncing change app-build-release. Update Purpose after archive.

## Requirements
### Requirement: App build only triggers for `app/**` changes

CI SHALL run the `test` and `build-and-release` jobs only when the triggering event touches `app/**` (or the `ci.yml` workflow file itself), for both `pull_request` and `push` events. A push to `main` that does not touch `app/**` SHALL NOT trigger an App build.

#### Scenario: Happy path — app change on main triggers a build

- **WHEN** a commit touching `app/**` is pushed to `main` and `test` succeeds
- **THEN** the `build-and-release` job runs and publishes a GitHub Release with the signed APK

#### Scenario: Error/rejection — unrelated push does not trigger a build

- **WHEN** a commit is pushed to `main` that only touches `services/**` or `deploy/**`
- **THEN** the `test` and `build-and-release` jobs do not run (skipped), and no GitHub Release is published

#### Scenario: Contract — gating does not depend on chained job conditions alone

- **WHEN** the `build-and-release` job's conditions are evaluated
- **THEN** it independently checks `needs.filter.outputs.app == 'true'` in addition to `needs.test.result == 'success'`, so its gating remains correct even if `test`'s own condition changes in the future

### Requirement: App build publishes a SHA-256 checksum alongside the APK

When CI publishes an App build, it SHALL compute a SHA-256 checksum of the signed release APK and publish it as a second asset on the same GitHub Release, named `<apk-name>.sha256`.

#### Scenario: Happy path — checksum published with the APK

- **WHEN** the `build-and-release` job builds and renames the APK to `Universal.apk`
- **THEN** CI computes its SHA-256 checksum, writes it to `Universal.apk.sha256`, and the GitHub Release includes both `Universal.apk` and `Universal.apk.sha256` as assets

#### Scenario: Error/rejection — checksum step failure blocks the release

- **WHEN** the checksum computation step fails (e.g. the APK file is missing)
- **THEN** the workflow fails before the release-creation step runs, and no GitHub Release is published

#### Scenario: Contract — checksum matches the published APK

- **WHEN** a user downloads `Universal.apk` and `Universal.apk.sha256` from the same Release
- **THEN** running `sha256sum -c Universal.apk.sha256` against the downloaded APK reports success

### Requirement: App build embeds a Build Tag for update checking

When CI publishes an App build, it SHALL pass the GitHub Release `tag_name` it is about to publish into the `flutter build apk` step via `--dart-define`, embedding it as a compile-time constant the running app can read as its own Build Tag.

#### Scenario: Happy path — built APK carries the release's own tag

- **WHEN** the `build-and-release` job computes its release `tag_name` and builds the APK
- **THEN** the APK is built with `--dart-define` set to that same `tag_name`, so the running app's Build Tag equals the tag of the release it ships in

#### Scenario: Error/rejection — missing tag fails the build

- **WHEN** the release tag cannot be computed before the `flutter build apk` step runs
- **THEN** the workflow fails before building the APK, and no GitHub Release is published

#### Scenario: Contract — dart-define key matches what the app reads

- **WHEN** CI passes the Build Tag via `--dart-define`
- **THEN** it uses the same key name that `UpdateService` reads via `String.fromEnvironment` in the app
