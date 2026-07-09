# deploy-manifest-pipeline Specification

## Purpose
Define the independent CI workflow that validates shared `deploy/` manifests while leaving `deploy/services/hello` to the hello-specific pipeline.

## Requirements
### Requirement: Deploy manifest linting is an independent workflow scoped to non-service manifests

`.github/workflows/ci-deploy.yml` SHALL use a native `paths` trigger (`on.push.paths` / `on.pull_request.paths`) scoped to `deploy/**` (excluding `deploy/services/hello/**`), `.yamllint.yml`, and the workflow file itself. Its `lint-deploy` job SHALL yamllint `deploy/`, `.yamllint.yml`, and `.github/`, then `kustomize build` and `kubeconform`-validate `deploy/bootstrap`, every directory under `deploy/infra/`, and every file under `deploy/apps/` — but SHALL NOT build or validate `deploy/services/hello`, since that is `hello-ci-pipeline`'s `validate-hello-manifests` job's responsibility.

#### Scenario: Happy path — infra manifest change validates cleanly

- **WHEN** a commit touching `deploy/infra/sealed-secrets/**` is pushed, and `kustomize build`/`kubeconform` succeed for every non-hello directory
- **THEN** `lint-deploy` succeeds

#### Scenario: Error/rejection — unrelated push does not trigger the workflow

- **WHEN** a commit is pushed to `main` that only touches `universal/**` or `services/hello/**`
- **THEN** `ci-deploy.yml` does not run at all (the file-level `paths` trigger excludes both, and `deploy/services/hello/**` is explicitly excluded even though it lives under `deploy/`)

#### Scenario: Contract — hello's manifests are excluded from this job's build set

- **WHEN** `lint-deploy` runs
- **THEN** it does not invoke `kustomize build` against `deploy/services/hello`, and a change only to that directory does not trigger `ci-deploy.yml` at all
