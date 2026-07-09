## MODIFIED Requirements

### Requirement: Image build and push to GHCR on merge to main

On push to `main` touching `services/hello/**`, CI SHALL build a `linux/amd64` image from `services/hello/Dockerfile` in the `push-hello` job, tag it with the short git SHA of the triggering commit, and push it to the public `ghcr.io/xdezex/universal/hello` repository. The short SHA SHALL be computed once by the upstream `build-hello` job and consumed by `push-hello` (and `deploy-hello`) via job outputs, rather than recomputed independently, and SHALL be passed as the `VERSION` build-arg baked into the binary, so the running image's `GET /` version always matches its tag. `push-hello` SHALL reuse `build-hello`'s Docker layers via a shared GitHub Actions cache (`cache-from`/`cache-to: type=gha`) instead of rebuilding from a cold cache. `push-hello` SHALL depend only on `test-hello` and `build-hello` succeeding — it SHALL NOT depend on `lint-deploy` or `validate-hello-manifests`, since pushing an image to GHCR is unrelated to `deploy/` manifest validity (an independently-versioned, independently-deployable artifact).

#### Scenario: Happy path — hello changes land on main

- **WHEN** a commit touching `services/hello/**` is pushed to `main` and `build-hello` and `test-hello` both succeed
- **THEN** `push-hello` builds a `linux/amd64` image reusing `build-hello`'s cached layers, tags it `<short-sha>` (the SHA output by `build-hello`), and pushes it to `ghcr.io/xdezex/universal/hello`

#### Scenario: Error/rejection — unrelated push

- **WHEN** a commit is pushed to `main` that does not touch `services/hello/**` (e.g. only `universal/` changes)
- **THEN** `ci-hello.yml` does not run at all, so neither `build-hello` nor `push-hello` runs

#### Scenario: Contract — tag matches baked version

- **WHEN** the image is built
- **THEN** the GHCR tag and the `-ldflags`-baked `version` string are the same short SHA — both sourced from `build-hello`'s `sha` output — so `GET /` on the running container reports exactly the tag that was deployed

### Requirement: Deploy commit bumps the running image tag

After both `push-hello` and `validate-hello-manifests` succeed, CI SHALL commit an update to `deploy/services/hello/kustomization.yaml`'s image tag to the new SHA (consumed from `push-hello`'s `sha` output) and push it directly to `main`, authored as `github-actions[bot]`, using a repository secret PAT scoped to `contents: write` only. Requiring `validate-hello-manifests` (rather than the broader, now-independent `lint-deploy`) ensures `deploy-hello` never commits a tag bump into a manifest tree it knows to be broken, without coupling to unrelated parts of `deploy/`.

#### Scenario: Happy path — deploy commit lands

- **WHEN** `push-hello` and `validate-hello-manifests` both succeed
- **THEN** a commit updating the image tag in `deploy/services/hello/kustomization.yaml` is authored as `github-actions[bot]` with message `deploy: hello@<short-sha>` and pushed to `main`

#### Scenario: Error/rejection — build failed

- **WHEN** `push-hello` fails
- **THEN** no deploy commit is made

#### Scenario: Error/rejection — hello's own manifests are invalid

- **WHEN** `push-hello` succeeds but `validate-hello-manifests` fails (e.g. `deploy/services/hello`'s kustomization no longer builds, perhaps due to an unrelated bad merge to `main`)
- **THEN** `deploy-hello` does not run, and no deploy commit bumps the tag into a manifest tree known to be broken

#### Scenario: Contract — push authenticates via the deploy PAT

- **WHEN** CI pushes the deploy commit to `main`
- **THEN** it authenticates using the repository secret PAT (not the default `GITHUB_TOKEN`), since `main`'s ruleset blocks direct pushes except from an account holding the ruleset's bypass

### Requirement: Image build validation runs on pull requests and is a required status check

`ci-hello.yml` SHALL use a native `paths` trigger (`on.push.paths` / `on.pull_request.paths`) scoped to `services/hello/**`, `deploy/services/hello/**`, and the workflow file itself, rather than a shared `dorny/paths-filter` job. Including `deploy/services/hello/**` ensures a commit that only edits that directory's manifests — including `deploy-hello`'s own automated tag-bump commit — still re-runs `validate-hello-manifests`, closing a coverage gap that would otherwise exist versus the pre-split `lint-deploy` job (which validated `deploy/services/hello` on any `deploy/**` change). CI SHALL run `build-hello` (a `docker build` with `push: false`) on pull requests and pushes touching `services/hello/**`, in parallel with `test-hello` and `validate-hello-manifests` rather than staged behind them. `build-hello` SHALL be a required status check on `main`'s branch ruleset. `build-hello` SHALL compute the short git SHA once and expose it as a job output for `push-hello` and `deploy-hello` to consume.

#### Scenario: Happy path — PR build validates the Dockerfile

- **WHEN** a pull request touching `services/hello/**` is opened and the Docker build succeeds
- **THEN** the `build-hello` check passes, without pushing any image to GHCR

#### Scenario: Error/rejection — a broken Dockerfile blocks merge

- **WHEN** a pull request touching `services/hello/**` introduces a change that fails to build (e.g. a broken `go build` inside the Dockerfile)
- **THEN** the `build-hello` job fails, and `main`'s branch ruleset blocks the pull request from merging

#### Scenario: Contract — push-hello reuses build-hello's cache instead of a cold rebuild

- **WHEN** `push-hello` runs after a successful `build-hello` on push to `main`
- **THEN** it builds using `cache-from: type=gha`, restoring the layers `build-hello` already populated via `cache-to: type=gha,mode=max`, rather than rebuilding every layer from scratch

## ADDED Requirements

### Requirement: Hello's own deploy manifests are validated independently of the shared deploy lint

`ci-hello.yml` SHALL run a `validate-hello-manifests` job that builds `deploy/services/hello` with `kustomize` and validates the result with `kubeconform`, scoped only to that directory. This job SHALL run in parallel with `test-hello`/`build-hello` (off the workflow's trigger directly, not staged behind `push-hello`), so a broken hello manifest is surfaced immediately rather than after an image has already been built and pushed. This replaces `hello`'s prior reliance on the repo-wide `lint-deploy` job (now `deploy-manifest-pipeline`, which no longer builds `deploy/services/hello` at all).

#### Scenario: Happy path — hello's manifests are valid

- **WHEN** `deploy/services/hello`'s kustomization builds cleanly and every resulting resource validates against its schema
- **THEN** `validate-hello-manifests` succeeds, independently of `test-hello`, `build-hello`, and any other pipeline

#### Scenario: Error/rejection — hello's manifests are broken

- **WHEN** `deploy/services/hello`'s kustomization fails to build, or `kubeconform` rejects a resulting resource
- **THEN** `validate-hello-manifests` fails, which blocks `deploy-hello` from running, but does not block `push-hello` (the image is still built and pushed to GHCR — only the deploy commit is withheld)

#### Scenario: Contract — validation is scoped to hello only

- **WHEN** `validate-hello-manifests` runs
- **THEN** it builds and validates only `deploy/services/hello`, not `deploy/bootstrap`, `deploy/infra/*`, or `deploy/apps/*` (those remain the responsibility of `deploy-manifest-pipeline`)
