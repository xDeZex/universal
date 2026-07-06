## ADDED Requirements

### Requirement: PRs touching `services/**` run Go tests as a required check

CI SHALL run `go test ./...` and `go vet ./...` against `services/hello` whenever a pull request or push touches `services/**`, and this check SHALL be a required status check on `main`'s branch ruleset.

#### Scenario: Happy path — tests pass

- **WHEN** a pull request modifies a file under `services/hello`, and its tests pass
- **THEN** the `test-hello` job succeeds and the PR is mergeable (assuming other checks pass)

#### Scenario: Error/rejection — tests fail

- **WHEN** a pull request modifies a file under `services/hello` and introduces a failing test
- **THEN** the `test-hello` job fails, and the branch ruleset blocks the PR from merging

---

### Requirement: Image build and push to GHCR on merge to main

On push to `main` touching `services/hello/**`, CI SHALL build a `linux/amd64` image from `services/hello/Dockerfile`, tag it with the short git SHA of the triggering commit, and push it to the public `ghcr.io/xdezex/universal/hello` repository. The same short SHA SHALL be passed as the `VERSION` build-arg baked into the binary, so the running image's `GET /` version always matches its tag.

#### Scenario: Happy path — hello changes land on main

- **WHEN** a commit touching `services/hello/**` is pushed to `main`
- **THEN** CI builds a `linux/amd64` image, tags it `<short-sha>`, and pushes it to `ghcr.io/xdezex/universal/hello`

#### Scenario: Error/rejection — unrelated push

- **WHEN** a commit is pushed to `main` that does not touch `services/hello/**` (e.g. only `app/` changes)
- **THEN** the build-and-push job does not run

#### Scenario: Contract — tag matches baked version

- **WHEN** the image is built
- **THEN** the GHCR tag and the `-ldflags`-baked `version` string are the same short SHA, so `GET /` on the running container reports exactly the tag that was deployed

---

### Requirement: Deploy commit bumps the running image tag

After a successful image push, CI SHALL commit an update to `deploy/services/hello/kustomization.yaml`'s image tag to the new SHA and push it directly to `main`, authored as `github-actions[bot]`, using a repository secret PAT scoped to `contents: write` only.

#### Scenario: Happy path — deploy commit lands

- **WHEN** the image build-and-push step succeeds
- **THEN** a commit updating the image tag in `deploy/services/hello/kustomization.yaml` is authored as `github-actions[bot]` with message `deploy: hello@<short-sha>` and pushed to `main`

#### Scenario: Error/rejection — build failed

- **WHEN** the image build-and-push step fails
- **THEN** no deploy commit is made

#### Scenario: Contract — push authenticates via the deploy PAT

- **WHEN** CI pushes the deploy commit to `main`
- **THEN** it authenticates using the repository secret PAT (not the default `GITHUB_TOKEN`), since `main`'s ruleset blocks direct pushes except from an account holding the ruleset's bypass
