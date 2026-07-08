## Why

The existing `build-and-release` CI job builds a signed APK and publishes it as a GitHub Release, but it doesn't actually gate on `app/**` changes — it inherits the `test` job's push condition, which currently runs (and therefore triggers a release) on **every** push to `main`, including pushes that only touch `services/**` or `deploy/**`. It also publishes no checksum, so there's no way to verify a downloaded APK wasn't corrupted or tampered with. Closing issue #105 requires the release to be strictly scoped to `app/**` changes and to ship a SHA-256 checksum alongside the APK.

## What Changes

- Tighten the `test` job's `if` condition from `needs.filter.outputs.app == 'true' || github.event_name == 'push'` to `needs.filter.outputs.app == 'true'`, so it only runs when `app/**` (or the workflow file itself) changed, for both `pull_request` and `push` events.
- Add an explicit `needs.filter.outputs.app == 'true'` condition to the `build-and-release` job, alongside its existing `needs.test.result == 'success'` check, so its gating doesn't silently depend on `test`'s condition staying in sync.
- Add a `sha256sum` step that computes a checksum of the renamed APK and writes it to `Universal.apk.sha256`.
- Include `Universal.apk.sha256` as a second file in the `softprops/action-gh-release` release assets, alongside `Universal.apk`.
- No change to the release tag scheme (`build-<timestamp>-<sha>`) — confirmed working, no problems reported.
- Add the **App build** term to `CONTEXT.md`, distinguishing this GitHub Release mechanism from **Deploy commit** (the Beelink/ArgoCD cluster-deploy concept), since both were at risk of being called "release" ambiguously.

## Capabilities

### New Capabilities
- `app-build-pipeline`: CI behavior that gates the signed-APK GitHub Release strictly on `app/**` changes to pushes on `main`, and publishes a SHA-256 checksum alongside the APK.

### Modified Capabilities
(none — no existing spec covers app CI/release behavior)

## Impact

- `.github/workflows/ci.yml`: `test` job condition, `build-and-release` job condition, new checksum step, updated release `files` list.
- `CONTEXT.md`: new "App build" glossary term.
- No application code, no deploy manifests, no database/API changes.
