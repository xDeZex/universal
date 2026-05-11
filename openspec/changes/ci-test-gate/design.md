## Context

Currently `.github/workflows/build-apk.yml` runs a single job on PRs to main and pushes to main/develop. Tests run as a step within that job, but the job also builds the APK and creates GitHub releases — work that is wasteful and inappropriate for PRs. There are no branch protection rules, so tests failing does not block merging.

## Goals / Non-Goals

**Goals:**
- Fast, cheap test gate for every PR (no APK build)
- Every push to main runs tests then builds and releases if tests pass
- Branch protection on `main` requires the `test` check to pass before merge is allowed
- Single workflow file — one place to reason about CI

**Non-Goals:**
- Test parallelisation or matrix builds
- Separate develop-branch builds (removed as not needed)
- Caching test results between runs

## Decisions

**Single workflow file with two jobs, not two separate files**

One `ci.yml` with `test` and `build-and-release` jobs. The alternative is two files (`test.yml` + `build-apk.yml`), but a single file makes the dependency between jobs explicit via `needs: test` and keeps the full CI picture in one place. Two files would require navigating between them to understand the full flow.

**`if: github.event_name == 'push'` on the build-and-release job**

This skips the build job on PRs entirely. The alternative is a separate branch condition like `if: github.ref == 'refs/heads/main'`, but `event_name == 'push'` is cleaner — a PR merge is a push event on main, so the condition is naturally correct without needing to also check the ref.

**`needs: test` on build-and-release**

Ensures build never runs if tests fail. GitHub skips a job with `needs` if the required job fails, so no extra `if` condition is needed to prevent releasing broken code.

**Branch protection requires `test` job, not the workflow**

Branch protection rules reference individual job names, not workflow names. Requiring the `test` job (not `build-and-release`) means PRs are not blocked waiting for a build that doesn't run on PRs. This is set manually in GitHub Settings → Branches after the workflow is merged.

## Risks / Trade-offs

- [Setup is split between code and GitHub UI] Branch protection must be configured manually in GitHub Settings after the workflow lands → document this in tasks
- [Removing develop-branch builds] The old workflow ran on pushes to `develop`; this change removes that. If the develop branch is used, builds there will no longer trigger → acceptable, not currently needed
- [First run after merge] Branch protection only activates after the rule is set; there is a brief window between merging `ci.yml` and setting the rule where unprotected merges are possible → set the rule immediately after the workflow PR merges

## Migration Plan

1. Open PR with `ci.yml` added and `build-apk.yml` deleted
2. Verify the `test` job runs and passes on the PR itself
3. Merge PR
4. Go to GitHub Settings → Branches → add branch protection rule for `main`: require status check `test` to pass
5. Verify a subsequent PR is blocked if tests fail
