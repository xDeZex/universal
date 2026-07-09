## Why

`.github/workflows/ci.yml` is one file shared by three independent pipelines (Universal build/release, hello build/push/deploy, deploy-manifest linting), computed via a single `dorny/paths-filter` job with four outputs. This has caused two real bugs already surfaced in this repo's history: (1) removing the `|| github.event_name == 'push'` fallback from `test-hello`/`lint-deploy` silently dropped their only safety net for `ci.yml`-only edits, while `app`/`deploy` kept theirs (asymmetric blind spot), and (2) `push-hello` and (until fixed) `release-universal` were gated on `lint-deploy`, coupling two independently-versioned, independently-deployable artifacts to an unrelated part of the tree (`deploy/bootstrap`, `deploy/infra/*`, `deploy/apps/*`) they never touch. Splitting into one workflow file per pipeline removes the shared-file coupling structurally instead of managing it via ever-growing filter lists, and each file's native path trigger is a strictly more precise mechanism than the shared `paths-filter` job it replaces. Separately, "app" is used as ambiguous, undefined prose in `CONTEXT.md` and the CI job graph itself already inconsistently mixes "app" (directory, filter output) with "universal" (job names, artifact names) — the project's actual name (`README.md`, `pubspec.yaml`, `Universal.apk`) — so this change also finishes that rename everywhere it appears.

## What Changes

- **BREAKING**: Rename the `app/` directory to `universal/` (Flutter project root moves).
- Split `.github/workflows/ci.yml` into three independent workflow files, each with its own native `on.push.paths`/`on.pull_request.paths` trigger (including its own filename, so editing a pipeline's own workflow file re-triggers it) instead of a shared `dorny/paths-filter` job:
  - `.github/workflows/ci-universal.yml`: `test-universal` (renamed from `test`) → `build-universal` → `release-universal`. Triggers on `universal/**` + itself.
  - `.github/workflows/ci-hello.yml`: `test-hello`, `build-hello`, and a new `validate-hello-manifests` job run in parallel off the trigger; `push-hello` needs `[test-hello, build-hello]` only (no longer needs `lint-deploy`); `deploy-hello` needs `[push-hello, validate-hello-manifests]`. Triggers on `services/hello/**`, `deploy/services/hello/**`, and itself — the latter so a direct manifest edit (including `deploy-hello`'s own tag-bump commit) still re-runs `validate-hello-manifests`.
  - `.github/workflows/ci-deploy.yml`: `lint-deploy`, now scoped to `deploy/bootstrap`, `deploy/infra/*`, and `deploy/apps/*` only (no longer builds/validates `deploy/services/hello`, since that moved into `validate-hello-manifests`). Triggers on `deploy/**` excluding `deploy/services/hello/**`, plus `.yamllint.yml` and itself.
- Remove the `filter` job and the `dorny/paths-filter` dependency entirely — each file now has exactly one governing path condition shared by all its jobs, which native trigger-level `paths:` filtering already expresses.
- Add `validate-hello-manifests`: a new job running `kustomize build deploy/services/hello | kubeconform`, scoped only to that directory, in parallel with `test-hello`/`build-hello` (not staged behind `push-hello`) so a broken hello manifest surfaces immediately instead of after the image is already built and pushed.
- No cross-workflow-file `needs:` exists anywhere after the split (mechanically impossible in GitHub Actions across separate workflow files, and — per the reasoning above — never actually the right design in the first place).
- Rename throughout: `app/` → `universal/`, `ci.yml` → the three files above, filter output `app` → n/a (removed), and `CONTEXT.md`'s **App release** → **Universal release** (with a new **Universal** term entry), fixing its cross-references in **Build Tag**, **Update Check**, and **Service**.

## Capabilities

### New Capabilities
- `universal-ci-pipeline`: CI behavior for the Flutter `Universal` app's own workflow file (`ci-universal.yml`) — triggers, job graph, and Build Tag/checksum behavior, superseding `app-build-pipeline` under the corrected name.
- `deploy-manifest-pipeline`: CI behavior for `ci-deploy.yml`'s `lint-deploy` job, now an independent workflow scoped to `deploy/bootstrap`, `deploy/infra/*`, and `deploy/apps/*` (explicitly excluding `deploy/services/hello`, which validates itself).

### Modified Capabilities
- `hello-ci-pipeline`: moves to its own workflow file (`ci-hello.yml`) with native path triggers instead of the shared `paths-filter` job; `push-hello` no longer needs `lint-deploy`; a new `validate-hello-manifests` job validates `deploy/services/hello` manifests in parallel with `test-hello`/`build-hello`; `deploy-hello` needs both `push-hello` and `validate-hello-manifests`.

## Impact

- `.github/workflows/ci.yml` deleted; replaced by `ci-universal.yml`, `ci-hello.yml`, `ci-deploy.yml`.
- `app/` directory renamed to `universal/` (all Flutter source, `pubspec.yaml`, `.flutter-version`, etc. move with it — no content changes).
- `openspec/specs/app-build-pipeline/spec.md`: requirements removed/superseded by `universal-ci-pipeline` (capability retired).
- `CONTEXT.md`: **App release** → **Universal release**, new **Universal** term, updated cross-references.
- `main`'s branch ruleset `required_status_checks`: job names referenced there (`test`, `build-universal`) need updating to `test-universal`, `build-universal` (unchanged), plus any new required checks (e.g. `validate-hello-manifests` if desired — left as an implementation decision in tasks).
- No application code changes; no runtime behavior changes to the app or the `hello` service itself.
