## Context

`.github/workflows/ci.yml` currently has two publish-shaped jobs — `build-and-release` (app APK) and `build-push-hello` (Docker image) — both gated to `push` events only via `github.event_name == 'push'` in their `if:`. Neither the Flutter/Gradle build nor the Docker build ever runs at PR time. `main`'s GitHub ruleset (id `16254768`) currently requires only `test` and `test-hello` as status checks, and `current_user_can_bypass: "always"` (solo-maintainer repo, admin can always override). This combination let a PR merge cleanly and then break `main`'s push-triggered build: an `ota_update` dependency needed Android core library desugaring enabled, and that only surfaced in `flutter build apk --release` after merge.

This design emerged from a `grill-with-docs` session; see `CONTEXT.md`'s **App release** entry for the terminology disambiguation from **Deploy commit** that came out of it.

## Goals / Non-Goals

**Goals:**
- Give PRs touching `app/**` or `services/hello/**` real compile/build-time signal before merge, not just after.
- Make that signal enforceable (required status check), not just visible.
- Avoid doubling build cost where avoidable (Docker layer cache; app's build-once-then-promote).
- Preserve existing publish-time guarantees (Build Tag/Release tag consistency, image tag/baked-version consistency).

**Non-Goals:**
- No change to APK signing. CI has no keystore secret, so the "release" build type is still debug-signed either way — orthogonal to this change.
- No change to `filter`, `lint-deploy` internals, or `test-hello`'s own trigger conditions.
- Not attempting true single-build for hello (i.e. not passing a saved/loaded image tarball between `build-hello` and `push-hello`) — Buildx layer cache reuse is judged sufficient for a small Go service's Dockerfile; the app's APK does get true single-build treatment because the artifact-download mechanism was already cheap and available (`actions/upload-artifact`/`download-artifact`).

## Decisions

**Two jobs per service (build + publish), not one job with step-level conditionals.**
Considered keeping `build-and-release` as a single job with `if: github.event_name == 'push'` guards on its trailing release-specific steps. Rejected because the resulting PR-time check would still be named `build-and-release` while only ever building — misleading — and because this repo's existing pattern already separates "verify" jobs (`test`, `test-hello`) from "publish" jobs; two jobs per service keeps that pattern consistent and gives each stage its own named status check.

**Build jobs run in parallel with test/lint, not staged behind them.**
The pre-existing `build-and-release`/`build-push-hello` waited on `needs: [test, lint-deploy]` before spending build time — reasonable when they only ran on push (don't spend a build on code that already failed). Now that `build-universal`/`build-hello` are meant to be the PR-time compile signal, staging them behind `test` would just add latency to the PR feedback loop for no correctness benefit — a compile failure is orthogonal to a test failure. The publish jobs (`release-universal`, `push-hello`) still explicitly `needs: [build-*, test(-hello), lint-deploy]` and check all three results, so nothing is published on top of a red test or lint run; only the build stage itself stopped waiting.

**Single source of truth for computed values, passed via job outputs.**
`build-universal` computes `sha`/`timestamp` once (already required to embed the Build Tag into the APK via `--dart-define`) and exposes them as outputs; `release-universal` consumes them rather than recomputing. This isn't optional: the Build Tag baked into the APK and the GitHub Release's `tag_name` must be byte-identical for `UpdateService`'s update check to work, and `timestamp` is wall-clock-derived — two independent computations in two jobs running at different times would diverge. The equivalent hello-side change (`build-hello` outputs `sha`, `push-hello`/`deploy-hello` consume it) is not load-bearing the same way — `git rev-parse --short HEAD` is commit-derived and deterministic regardless of which job runs it — but is applied anyway for consistency with the established `deploy-hello`-consumes-upstream-`sha`-output pattern already in this file, and to avoid three independent `git rev-parse` steps doing the same thing.

**App: build once, download-and-promote. Hello: rebuild with cache reuse.**
The app already needed `actions/upload-artifact` (it uploads `Universal.apk` as a workflow artifact today). Extending that so `release-universal` downloads the same artifact rather than re-running `flutter build apk` is a small change and gives a true build-once guarantee — the exact bytes validated at build time are the exact bytes released. Hello's Docker image doesn't have an equivalent lightweight hand-off primitive in this workflow (would require `docker save`/`load` and artifact upload of a tarball, more machinery than a small Go service's Dockerfile warrants) — so `push-hello` re-runs `docker build --push`, made cheap via `cache-from`/`cache-to: type=gha` reusing `build-hello`'s layers instead of a cold rebuild. Without this cache, the split would silently double Docker build time for zero benefit.

**Both build jobs always upload their artifact, including on PR runs.**
Zero-cost byproduct of a build that's already running; lets a PR's APK be downloaded and sideloaded for manual testing before merge.

**Add `~/.pub-cache` caching to `build-universal` and `test`.**
Pre-existing gap — only `~/.gradle/caches` was cached; `flutter pub get` always ran cold. Not caused by this change, but this change increases how often that cost is paid (every app-touching PR, not just merges to `main`), so it's the natural moment to close it.

## Risks / Trade-offs

- **[Risk]** `push-hello`'s GHA cache (`cache-to: type=gha,mode=max`) adds cache storage/eviction to reason about if it ever misbehaves (stale layers, cache size limits) → **[Mitigation]** `mode=max` is the standard Buildx recommendation for this exact build+validate-then-push shape; if cache staleness ever causes a wrong image, `push-hello` can drop `cache-from` for a one-off cold rebuild without any workflow restructuring.
- **[Risk]** Required status checks (`build-universal`, `build-hello`) run more Gradle/Docker builds per week (every PR, not just merges) → **[Mitigation]** solo-maintainer repo with low PR volume; pub-cache and Gradle cache reuse keep marginal cost low; `current_user_can_bypass: "always"` remains available if a build job is ever wrongly red and blocking is undesired.
- **[Risk]** `release-universal` depends on `build-universal`'s artifact existing; if the artifact's default retention (30 days, unchanged) ever expires between build and release — not possible in practice, since `release-universal` only runs `needs: build-universal` within the same workflow run, so the artifact is always freshly produced seconds earlier → no mitigation needed, noted only to rule it out.

## Migration Plan

1. Edit `.github/workflows/ci.yml`: perform the job splits described in the proposal.
2. Update the GitHub ruleset (`gh api` or the UI) for ruleset id `16254768`, adding `build-universal` and `build-hello` to `required_status_checks.required_status_checks` (same `integration_id` as the existing entries).
3. Open a PR touching both `app/**` and `services/hello/**` (or two PRs) to confirm `build-universal`/`build-hello` actually appear and pass as required checks before merging this change itself.
4. No rollback complexity beyond reverting the workflow file and the ruleset addition — no data migration, no runtime behavior change outside CI.
