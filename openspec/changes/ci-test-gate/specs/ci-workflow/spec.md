## ADDED Requirements

### Requirement: Test job runs on PRs and pushes to main
The CI workflow SHALL run a `test` job on every pull request targeting `main` and every push to `main`. The job SHALL run `flutter test` and `flutter analyze` and fail the job if either command exits with a non-zero code.

#### Scenario: PR with passing tests
- **WHEN** a pull request is opened or updated targeting `main`
- **THEN** the `test` job runs and reports a passing status check

#### Scenario: PR with failing tests
- **WHEN** a pull request is opened or updated targeting `main` and `flutter test` exits non-zero
- **THEN** the `test` job reports a failing status check and the PR cannot be merged

#### Scenario: Push to main with passing tests
- **WHEN** a commit is pushed to `main`
- **THEN** the `test` job runs and passes before the `build-and-release` job begins

### Requirement: Build-and-release job runs only on push to main
The CI workflow SHALL run a `build-and-release` job only when the trigger is a push event (not a pull_request event). This job SHALL depend on the `test` job via `needs: test` and SHALL be skipped if `test` fails.

#### Scenario: Push to main after passing tests
- **WHEN** a commit is pushed to `main` and the `test` job passes
- **THEN** the `build-and-release` job runs, builds the APK, uploads it as an artifact, and creates a GitHub release

#### Scenario: Push to main after failing tests
- **WHEN** a commit is pushed to `main` and the `test` job fails
- **THEN** the `build-and-release` job is skipped and no release is created

#### Scenario: Pull request trigger
- **WHEN** the workflow is triggered by a pull request event
- **THEN** the `build-and-release` job is skipped entirely

### Requirement: Branch protection gates merges on test job
The `main` branch SHALL have a branch protection rule requiring the `test` status check to pass before any pull request can be merged.

#### Scenario: Test check required before merge
- **WHEN** a pull request's `test` job has not yet passed
- **THEN** the merge button is disabled on GitHub

#### Scenario: Failed test blocks merge
- **WHEN** the `test` job fails on a pull request
- **THEN** the pull request cannot be merged until the failure is resolved
