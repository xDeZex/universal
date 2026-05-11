## Why

The existing `build-apk.yml` workflow couples test execution with APK building, meaning PRs trigger a full build pipeline just to verify tests pass. There is also no branch protection enforcing that tests must pass before merging.

## What Changes

- Replace `build-apk.yml` with a new `ci.yml` workflow containing two jobs: `test` and `build-and-release`
- `test` job runs on all PRs and pushes to main (flutter test + flutter analyze)
- `build-and-release` job runs only on push to main, gated by `needs: test`
- Delete the old `build-apk.yml`
- Branch protection rule on `main` requires the `test` job to pass before merge

## Capabilities

### New Capabilities

- `ci-workflow`: A single GitHub Actions workflow file with a fast test gate job and a conditional build-and-release job

### Modified Capabilities

## Impact

- `.github/workflows/build-apk.yml`: deleted
- `.github/workflows/ci.yml`: created
- GitHub repository branch protection settings: `main` branch requires `test` check to pass
