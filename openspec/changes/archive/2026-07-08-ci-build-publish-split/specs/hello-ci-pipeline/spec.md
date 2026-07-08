## MODIFIED Requirements

### Requirement: Image build and push to GHCR on merge to main

On push to `main` touching `services/hello/**`, CI SHALL build a `linux/amd64` image from `services/hello/Dockerfile` in the `push-hello` job, tag it with the short git SHA of the triggering commit, and push it to the public `ghcr.io/xdezex/universal/hello` repository. The short SHA SHALL be computed once by the upstream `build-hello` job and consumed by `push-hello` (and `deploy-hello`) via job outputs, rather than recomputed independently, and SHALL be passed as the `VERSION` build-arg baked into the binary, so the running image's `GET /` version always matches its tag. `push-hello` SHALL reuse `build-hello`'s Docker layers via a shared GitHub Actions cache (`cache-from`/`cache-to: type=gha`) instead of rebuilding from a cold cache.

#### Scenario: Happy path — hello changes land on main

- **WHEN** a commit touching `services/hello/**` is pushed to `main` and `build-hello`, `test-hello`, and `lint-deploy` all succeed
- **THEN** `push-hello` builds a `linux/amd64` image reusing `build-hello`'s cached layers, tags it `<short-sha>` (the SHA output by `build-hello`), and pushes it to `ghcr.io/xdezex/universal/hello`

#### Scenario: Error/rejection — unrelated push

- **WHEN** a commit is pushed to `main` that does not touch `services/hello/**` (e.g. only `app/` changes)
- **THEN** neither `build-hello` nor `push-hello` runs

#### Scenario: Contract — tag matches baked version

- **WHEN** the image is built
- **THEN** the GHCR tag and the `-ldflags`-baked `version` string are the same short SHA — both sourced from `build-hello`'s `sha` output — so `GET /` on the running container reports exactly the tag that was deployed

### Requirement: Deploy commit bumps the running image tag

After `push-hello` succeeds, CI SHALL commit an update to `deploy/services/hello/kustomization.yaml`'s image tag to the new SHA (consumed from `push-hello`'s `sha` output) and push it directly to `main`, authored as `github-actions[bot]`, using a repository secret PAT scoped to `contents: write` only.

#### Scenario: Happy path — deploy commit lands

- **WHEN** `push-hello` succeeds
- **THEN** a commit updating the image tag in `deploy/services/hello/kustomization.yaml` is authored as `github-actions[bot]` with message `deploy: hello@<short-sha>` and pushed to `main`

#### Scenario: Error/rejection — build failed

- **WHEN** `push-hello` fails
- **THEN** no deploy commit is made

#### Scenario: Contract — push authenticates via the deploy PAT

- **WHEN** CI pushes the deploy commit to `main`
- **THEN** it authenticates using the repository secret PAT (not the default `GITHUB_TOKEN`), since `main`'s ruleset blocks direct pushes except from an account holding the ruleset's bypass

## ADDED Requirements

### Requirement: Image build validation runs on pull requests and is a required status check

CI SHALL run `build-hello` (a `docker build` with `push: false`) on pull requests and pushes touching `services/hello/**`, in parallel with `test-hello` and `lint-deploy` rather than staged behind them. `build-hello` SHALL be a required status check on `main`'s branch ruleset. `build-hello` SHALL compute the short git SHA once and expose it as a job output for `push-hello` and `deploy-hello` to consume.

#### Scenario: Happy path — PR build validates the Dockerfile

- **WHEN** a pull request touching `services/hello/**` is opened and the Docker build succeeds
- **THEN** the `build-hello` check passes, without pushing any image to GHCR

#### Scenario: Error/rejection — a broken Dockerfile blocks merge

- **WHEN** a pull request touching `services/hello/**` introduces a change that fails to build (e.g. a broken `go build` inside the Dockerfile)
- **THEN** the `build-hello` job fails, and `main`'s branch ruleset blocks the pull request from merging

#### Scenario: Contract — push-hello reuses build-hello's cache instead of a cold rebuild

- **WHEN** `push-hello` runs after a successful `build-hello` on push to `main`
- **THEN** it builds using `cache-from: type=gha`, restoring the layers `build-hello` already populated via `cache-to: type=gha,mode=max`, rather than rebuilding every layer from scratch
