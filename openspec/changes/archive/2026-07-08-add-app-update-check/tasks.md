## 1. CI embeds a Build Tag in the APK

- [x] 1.1 `ci.yml`'s `build-and-release` job computes its release tag_name (matching the existing `tag_name:` expression) before the `flutter build apk` step
- [x] 1.2 `flutter build apk --release` is invoked with `--dart-define=BUILD_TAG=<computed tag>`
- [x] 1.3 A workflow run's built APK, when inspected via `String.fromEnvironment('BUILD_TAG')`, equals the `tag_name` of the GitHub Release it ships in

## 2. `UpdateService` detects available updates

- [x] 2.1 `app/pubspec.yaml` adds `http`, `provider`, and `ota_update` dependencies
- [x] 2.2 `app/lib/services/update_service.dart` defines `UpdateService extends ChangeNotifier` with states `checking` / `upToDate` / `updateAvailable` / `error`
- [x] 2.3 `UpdateService.checkForUpdate()` calls `GET https://api.github.com/repos/xDeZex/universal/releases/latest`, reads `tag_name`, and compares it (string equality) to `String.fromEnvironment('BUILD_TAG', defaultValue: 'dev')`
- [x] 2.4 A non-2xx response or network exception sets state to `error` without throwing
- [x] 2.5 A matching tag sets state to `upToDate`; a differing tag sets state to `updateAvailable` and stores the latest release's asset URLs (APK + `.sha256`)
- [x] 2.6 Unit tests cover: matching tags, differing tags, and a failed request, using a fake/mocked HTTP client

## 3. App launch and Settings wire up the Update Check

- [x] 3.1 `app/lib/main.dart` wraps the app in `ChangeNotifierProvider<UpdateService>` and triggers `checkForUpdate()` once on launch
- [x] 3.2 `app/lib/screens/home_screen.dart` gains an AppBar icon that navigates to a new `SettingsScreen`, showing a badge dot (via `context.watch<UpdateService>()`) when state is `updateAvailable`
- [x] 3.3 The badge remains visible across screen navigation until `UpdateService` state returns to `upToDate` (i.e. not dismissed merely by opening Settings)
- [x] 3.4 `app/lib/screens/settings_screen.dart` calls `checkForUpdate()` in `initState`/on each open, and renders the current state (checking / up to date / update available / error) with a Download button shown only when `updateAvailable`
- [x] 3.5 Widget tests cover: badge visibility toggling with `UpdateService` state, and Settings screen rendering for each of the four states

## 4. Download, verify, and install

- [x] 4.1 `UpdateService.downloadAndInstall()` downloads the APK via `ota_update`, exposing progress updates for the Settings screen to render
- [x] 4.2 Before firing the install intent, the downloaded APK's SHA-256 is computed and compared against the release's `.sha256` asset content
- [x] 4.3 A checksum mismatch surfaces an error state, discards the downloaded file, and does not fire the install intent
- [x] 4.4 A verified checksum fires the Android install intent and optimistically sets `UpdateService` state to `upToDate`
- [x] 4.5 `app/android/app/src/main/AndroidManifest.xml` adds the `REQUEST_INSTALL_PACKAGES` permission and required `FileProvider` entries
- [x] 4.6 Unit tests cover: matching checksum proceeds to install, mismatched checksum blocks install

## 5. Verification

- [x] 5.1 `flutter test` passes for all new and existing tests
- [x] 5.2 `flutter analyze` reports no new warnings
