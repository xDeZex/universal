## ADDED Requirements

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
