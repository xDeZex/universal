## Why

Users currently have no way to know a newer App build exists or to install it without manually visiting GitHub Releases. The CI release pipeline (`app-build-pipeline`) already publishes a signed APK with a SHA-256 checksum on every App build, so the app can now check against it directly.

## What Changes

- CI bakes the release's own `tag_name` (Build Tag) into the APK at build time via `--dart-define`, so a running app knows which App build it is.
- New `UpdateService` in `app/lib/services/`, exposed via Provider, that calls `GET /repos/xDeZex/universal/releases/latest` and compares the returned `tag_name` against the app's own baked-in Build Tag (string equality — see ADR-0013).
- Update Check runs on app launch and again every time the Settings screen opens (no throttling, no manual retry).
- New Settings screen reachable from a new AppBar icon on the home screen; the icon shows a badge dot when an update is available, staying lit until the update is installed.
- Settings screen shows current Update Check status (checking / up to date / update available / error) and a Download action when an update is available.
- Tapping Download downloads the APK via the `ota_update` package, verifies it against the published `.sha256`, and fires the Android install intent on success, with progress shown in the UI.
- Adds `REQUEST_INSTALL_PACKAGES` permission and required manifest entries (FileProvider paths, etc.) to `app/android/app/src/main/AndroidManifest.xml`.

## Capabilities

### New Capabilities
- `app-update-check`: In-app detection of a newer App build (Update Check, Settings screen badge/status, download+verify+install flow).

### Modified Capabilities
- `app-build-pipeline`: CI now bakes the release's `tag_name` into the built APK via `--dart-define`, so the running app can identify its own Build Tag.

## Impact

- `app/lib/services/`: new `update_service.dart`.
- `app/lib/screens/`: new `settings_screen.dart`; `home_screen.dart` gains an AppBar icon + badge.
- `app/android/app/src/main/AndroidManifest.xml`: new permission and FileProvider entries.
- `app/pubspec.yaml`: adds `ota_update` (and any HTTP client already in use) as a dependency.
- `.github/workflows/ci.yml`: `build-and-release` job passes `--dart-define` with the release tag at build time.
