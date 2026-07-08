# app-update-check Specification

## Purpose
TBD - created by syncing change add-app-update-check. Update Purpose after archive.

## Requirements
### Requirement: Update Check compares Build Tags on launch and Settings open

The app SHALL run an Update Check when it launches, and again every time the Settings screen is opened, comparing its own baked-in Build Tag to the `tag_name` of `GET /repos/xDeZex/universal/releases/latest`. The check SHALL run in the background without blocking the UI, and SHALL NOT be throttled between runs.

#### Scenario: Happy path — differing tags report an update available

- **WHEN** the Update Check receives a `tag_name` that differs from the app's own Build Tag
- **THEN** the Update Check state becomes "update available"

#### Scenario: Error/rejection — network failure surfaces an error state

- **WHEN** the request to GitHub's releases API fails (timeout, no connectivity, non-2xx response)
- **THEN** the Update Check state becomes "error" and no update-available badge is shown

#### Scenario: Contract — request targets the correct releases endpoint

- **WHEN** the Update Check runs
- **THEN** it issues `GET https://api.github.com/repos/xDeZex/universal/releases/latest` and reads the `tag_name` field of the JSON response

### Requirement: Settings screen surfaces Update Check status via badge and detail view

The home screen SHALL show an AppBar icon that opens the Settings screen, displaying a badge dot on that icon whenever the current Update Check state is "update available." The badge SHALL remain visible until the update is installed, regardless of how many times Settings is opened or closed. The Settings screen SHALL display the current Update Check state (checking / up to date / update available / error).

#### Scenario: Happy path — badge appears and leads to Settings detail

- **WHEN** the Update Check state is "update available"
- **THEN** the home screen's Settings icon shows a badge dot, and opening Settings shows "update available" with a Download action

#### Scenario: Error/rejection — errored check shows no badge

- **WHEN** the Update Check state is "error"
- **THEN** the home screen's Settings icon shows no badge, and the Settings screen shows the error state without a Download action

### Requirement: Downloading an update verifies its checksum before installing

Tapping Download on the Settings screen SHALL download the APK asset from the latest release via the `ota_update` package, show download progress in the UI, verify the downloaded file against the release's published `.sha256` asset, and only then fire the Android install intent.

#### Scenario: Happy path — verified download triggers install

- **WHEN** the downloaded APK's SHA-256 matches the published `.sha256` asset
- **THEN** the app fires the Android install intent for the downloaded APK

#### Scenario: Error/rejection — checksum mismatch blocks installation

- **WHEN** the downloaded APK's SHA-256 does not match the published `.sha256` asset
- **THEN** the app shows an error, does not fire the install intent, and discards the downloaded file

#### Scenario: Contract — download targets the release's published assets

- **WHEN** the user taps Download
- **THEN** the app downloads the APK and `.sha256` assets from the same GitHub Release identified by the Update Check
