## Context

The app currently has no networking dependency and no shared cross-screen state mechanism — `checklist_screen.dart` and `home_screen.dart` both use plain `StatefulWidget`/`setState`, even though `app/lib/CLAUDE.md` mandates the Provider pattern for state. This is the first feature that genuinely needs state shared between two screens (the home screen's badge and the Settings screen's status/Download action), so it's the natural point to introduce `provider`.

The CI release pipeline (`app-build-pipeline`) already publishes a GitHub Release with a signed APK and `.sha256` on every App build, tagged `build-<timestamp>-<sha>`. There's no numeric version scheme (see ADR-0013), so update detection is a Build Tag equality check, not a version comparison.

## Goals / Non-Goals

**Goals:**
- Detect when a newer App build exists, without blocking app startup.
- Let the user install that update from within the app, with checksum verification before the install intent fires.
- Introduce `provider` for this feature's state, consistent with `CLAUDE.md`.

**Non-Goals:**
- No numeric/semantic versioning scheme — Build Tag comparison is equality-only (ADR-0013).
- No iOS support — `ota_update` and the install-intent flow are Android-only, matching the app's current Android-only distribution via GitHub Releases.
- No retry throttling/cooldown on the Update Check (personal, low-traffic app).
- No background/periodic checking outside of launch and Settings-open — no WorkManager/background service.

## Decisions

**State management: `provider` + `ChangeNotifier`**
`UpdateService` extends `ChangeNotifier` and is provided at the app root (`main.dart`) via `ChangeNotifierProvider`, so both `HomeScreen` (badge) and `SettingsScreen` (status/Download) rebuild from the same instance via `context.watch`/`context.read`. Alternative considered: keep passing callbacks/state down through constructors like the existing screens do — rejected because the badge (home) and detail (Settings) are siblings, not parent/child, making prop-drilling awkward, and because introducing `provider` here fulfills the CLAUDE.md mandate rather than deferring it further.

**Build Tag delivery: `--dart-define` read via `String.fromEnvironment`**
CI passes `--dart-define=BUILD_TAG=<tag_name>` to `flutter build apk`; the app reads it with `const String.fromEnvironment('BUILD_TAG', defaultValue: 'dev')`. Alternative considered: a generated Dart file written by CI before build — rejected as an unnecessary extra CI step when `--dart-define` does this natively and is already a supported Flutter mechanism.

**HTTP client: `http` package**
Adds the `http` package (no auth needed — GitHub's releases API is unauthenticated for public repos, within the 60 req/hour unauthenticated rate limit, acceptable per the earlier no-throttling decision). Alternative considered: `dio` — rejected as unnecessary weight for a single unauthenticated GET.

**Download/install: `ota_update` package**
As scoped in the proposal. It handles the Android download-and-install-intent flow directly; the SHA-256 verification of the downloaded APK against the release's `.sha256` asset happens in `UpdateService` before invoking `ota_update`'s install step (fetch `.sha256` content separately via `http`, hash the downloaded file, compare).

**Badge persistence: derived from live state, not stored**
The badge is simply "current `UpdateService` state == update available" — no separate persisted "seen" flag, matching the earlier decision that the badge stays lit until installed rather than being dismissible. After a successful install-intent launch, `UpdateService` optimistically clears to "up to date" (final confirmation happens on next launch's Update Check, once the new Build Tag is actually running).

## Risks / Trade-offs

- **[Risk]** GitHub's unauthenticated rate limit (60/hour/IP) could be hit if a user repeatedly reopens Settings. → **Mitigation**: accepted per earlier decision (no throttling) given this is a personal, single-user app; revisit if it becomes a problem.
- **[Risk]** `--dart-define` values are visible in the compiled APK (not a secret) but this is fine since the Build Tag is public release metadata already. → **Mitigation**: none needed, not sensitive data.
- **[Risk]** Optimistically clearing the badge after firing the install intent could be wrong if the user cancels the Android install dialog. → **Mitigation**: acceptable given the badge will re-appear on the next launch's Update Check if the install didn't actually happen, since the Build Tag will still differ.
- **[Trade-off]** Introducing `provider` only for this feature means the rest of the app (checklist screens) remains on `setState`, so the codebase temporarily has two state patterns side by side. Migrating existing screens is out of scope here.

## Migration Plan

- No data migration. This is purely additive: new service, new screen, new CI build flag, new Android manifest entries.
- Rollback: revert the change; the CI `--dart-define` addition is harmless to leave in even without the app-side feature, but can be reverted together for cleanliness.

## Open Questions

- None outstanding — the grill-with-docs session resolved terminology and behavior; remaining choices are implementation detail covered above.
