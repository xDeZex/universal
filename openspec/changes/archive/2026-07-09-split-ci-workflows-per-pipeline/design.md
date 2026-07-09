## Context

`.github/workflows/ci.yml` currently hosts three independent pipelines (Universal app build/release, hello build/push/deploy, deploy-manifest linting) behind one `dorny/paths-filter` job with four boolean outputs (`deploy`, `services`, `hello`, `app`). This grew organically as each pipeline was added, and two coupling bugs have already surfaced from it:

1. Removing the `|| github.event_name == 'push'` fallback from `test-hello`/`lint-deploy` (to stop wasteful/flaky unconditional runs) silently removed their only protection against `ci.yml`-only edits going unvalidated, while `app`/`deploy` — which explicitly list `ci.yml` in their filter paths — kept that protection. This asymmetry was undetected until this change's exploration.
2. `push-hello` (and, until a prior fix, `release-universal`) depended on `lint-deploy`, coupling an unrelated artifact (a Docker image push, or an APK release) to whether `deploy/bootstrap`/`deploy/infra/*`/`deploy/apps/*` manifests happen to validate — files neither pipeline touches.

Separately, `CONTEXT.md` and the CI job graph use "app" as undefined, ambiguous prose (the directory is `app/`, the filter output is `app`) while the actual jobs (`build-universal`, `release-universal`) and every build artifact (`Universal.apk`, `pubspec.yaml`'s `name: universal`, `README.md`'s title) already say "Universal." This change finishes that rename everywhere it appears, since doing it now (while every reference to the old path/term is being touched anyway) is far cheaper than doing it as a separate pass later.

## Goals / Non-Goals

**Goals:**
- Eliminate cross-pipeline coupling structurally (separate workflow files with no cross-file `needs:`), not by maintaining longer path-filter lists.
- Give each pipeline its own native `paths` trigger, replacing the shared `dorny/paths-filter` job.
- Move hello's own deploy-manifest validation (`validate-hello-manifests`) into hello's own pipeline, running in parallel with `test-hello`/`build-hello` for fast feedback, and gating only `deploy-hello` (the job that actually writes to `deploy/`) — not `push-hello`.
- Shrink `lint-deploy`'s scope to the manifests that have no other owning pipeline (`bootstrap`, `infra/*`, `apps/*`), now the sole purpose of `ci-deploy.yml`.
- Finish the `app` → `Universal` rename: directory, workflow file, job names, `CONTEXT.md` terms.

**Non-Goals:**
- Generalizing `ci-hello.yml` into a reusable/matrix workflow for future services — YAGNI until a second Go service exists (see proposal discussion).
- Changing any application code, runtime behavior of `hello`, or the Flutter app itself.
- Splitting `lint-deploy`'s remaining scope (`bootstrap`/`infra/*`/`apps/*`) further per-component — none of those have a dedicated build/test pipeline of their own today, so one shared job remains their only validation, which is appropriate.

## Decisions

**Three workflow files, zero cross-file `needs:`.** GitHub Actions cannot express a `needs:` dependency across separate workflow files, which forces resolving every cross-pipeline coupling rather than working around the file boundary (e.g. via `workflow_run`). Investigation showed every existing cross-file coupling (`push-hello`/`release-universal` → `lint-deploy`) was already a design smell — an unrelated artifact blocked on unrelated manifest validation — so the mechanical constraint and the correct design point the same direction. The one exception (`deploy-hello` caring about hello's own manifests) is resolved by moving that validation *into* `ci-hello.yml` as `validate-hello-manifests`, rather than depending on `ci-deploy.yml`.

**Native `paths` triggers replace `dorny/paths-filter`.** The shared filter job existed to compute four different outputs from one trigger for four different consumers. Once split, each file has exactly one governing condition shared by every job in it — precisely what `on.push.paths`/`on.pull_request.paths` already expresses natively, with no extra job, no pinned third-party action, and no `needs: filter`/`if: needs.filter.outputs.x` boilerplate repeated on every job.

**`validate-hello-manifests` runs early and gates only `deploy-hello`.** The check only reads `deploy/services/hello/**` at the current commit — it doesn't depend on the image being built or pushed — so running it in parallel with `test-hello`/`build-hello` costs nothing and surfaces a broken manifest immediately instead of after `push-hello` completes. It must NOT gate `push-hello`: per the "build once, deploy many" principle, publishing a tested, immutable image artifact is independent of whether that artifact can currently be deployed. Gating the deploy commit (`deploy-hello`) on it, rather than trusting that PR-time checks already covered it, defends against semantic-merge-conflict scenarios where `main` is briefly broken by the combination of two individually-passing PRs.

**`lint-deploy` shrinks rather than disappears.** `deploy/bootstrap`, `deploy/infra/*`, and `deploy/apps/*` have no other pipeline — no build/test/push step exists for Sealed Secrets, the DuckDNS updater, or the root Application list. `lint-deploy` is their only validation, so it stays, just scoped down to exclude `deploy/services/hello` (now self-validated).

**Full rename over vocabulary-only.** The codebase already mixed "app" (directory, filter output) and "universal" (job/artifact names) — a live example of the exact confusion this change is trying to eliminate elsewhere. Doing the directory rename now, while touching every CI reference to `app/` anyway, avoids a second disruptive pass later purely for cosmetic consistency.

## Risks / Trade-offs

- **[Risk]** Renaming `app/` → `universal/` touches Flutter tooling paths (`pubspec.yaml`, `.flutter-version`, Android/iOS platform folders, CI `working-directory:` references) — a mechanical but wide-reaching change. → **Mitigation**: it's a pure path rename with no content changes; verify with `flutter pub get` + `flutter analyze` + `flutter test` post-rename before touching CI.
- **[Risk]** `main`'s branch ruleset references required status check names (`test`, `build-universal`) by string; renaming `test` → `test-universal` will silently stop it from being enforced until the ruleset is updated. → **Mitigation**: update the ruleset's `required_status_checks` in the same change, and confirm via a test PR that the renamed checks appear as required before merging.
- **[Risk]** Splitting into three files means three separate Actions run histories going forward (harder to see "all CI for this commit" in one place). → **Mitigation**: accepted — GitHub's checks UI already aggregates all workflow runs for a commit/PR regardless of file count; this is a cosmetic navigation change, not a loss of information.
- **[Risk]** Duplicating kustomize/kubeconform setup between `validate-hello-manifests` and `lint-deploy` (two jobs, two files) instead of one shared job. → **Mitigation**: accepted — both already reuse the existing `./.github/actions/setup-kustomize` composite action; the duplicated logic is ~10 lines of `kustomize build | kubeconform`, a worthwhile cost for full pipeline independence.
- **[Risk]** Scoping `ci-hello.yml`'s trigger to `services/hello/**` alone (mirroring the old `hello` filter output) would silently drop coverage the old `deploy` filter (`deploy/**`, unrestricted) used to provide: a commit touching only `deploy/services/hello/**` — including `deploy-hello`'s own automated tag-bump commit — would trigger neither `ci-hello.yml` nor the now-excluded `ci-deploy.yml`, so `validate-hello-manifests` would never re-run against it. → **Mitigation**: `ci-hello.yml`'s trigger also includes `deploy/services/hello/**`, so any direct edit to hello's own manifests (manual or bot-authored) re-validates them, matching the pre-split coverage.

## Migration Plan

1. Rename `app/` → `universal/` in isolation; verify Flutter build/test/analyze locally before touching CI.
2. Update `CONTEXT.md` terms (already done during exploration — see `split-ci-workflows-per-pipeline`'s proposal).
3. Create the three new workflow files; delete `.github/workflows/ci.yml` in the same commit (no dual-running period — the old file's jobs would otherwise duplicate work against the same paths).
4. Update `main`'s branch ruleset required status checks to match renamed/new job names (`test-universal`, `build-universal`; decide whether `validate-hello-manifests` becomes required too).
5. Open as a PR touching both `universal/**` and `.github/workflows/**` so all three new workflows self-validate on the PR itself before merging.

No rollback beyond `git revert` — this is a CI-only, non-runtime change with no data migration.

## Open Questions

- Should `validate-hello-manifests` be added to `main`'s required status checks, or left informational for now? (Left as a task-level decision — no strong reason surfaced either way during exploration.)
