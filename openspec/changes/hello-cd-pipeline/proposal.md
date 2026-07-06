## Why

Issue #9 ("CI: build linux/arm64 image to GHCR and bump tag in `deploy/`") was closed after only the Dockerfile landed — the actual build/push/deploy pipeline was never built, and nothing currently deploys `hello` to the cluster. There's also no CI job testing `services/hello` at all, so the pipeline being proposed would happily build and deploy an untested image. This blocks issue #10 (exposing `hello` externally), which needs a running Service to route to.

## What Changes

- Add a `test-hello` CI job (`go test ./...`, `go vet ./...`) gated on `services/**` changes, added as a required status check on `main`'s ruleset alongside the existing `test` (Flutter) check
- Add a CI job that builds `linux/amd64` from `services/hello/Dockerfile` on push to `main`, tags it with the short git SHA (same SHA baked into the binary's `version` via `-ldflags`, so `GET /` always matches the running image), and pushes to `ghcr.io/xdezex/universal/hello` (public — no `imagePullSecret` needed)
- Add a CI job that bumps the image tag in `deploy/services/hello/kustomization.yaml` and commits directly to `main` (the Deploy commit), authored as `github-actions[bot]`, using a repo secret PAT (`contents: write` only) that rides the existing admin ruleset bypass — no new bypass actor
- Add `deploy/apps/hello.yaml` — the `Application` CRD, following the existing app-of-apps pattern (root app watches `deploy/apps/` for `Application` files only)
- Add `deploy/services/hello/` — `kustomization.yaml`, `deployment.yaml` (1 replica, liveness/readiness wired to `/healthz`), `service.yaml` (ClusterIP, port 8080), all in a new shared `services` namespace
- Fix the stale `CONTEXT.md:37` dialogue line ("the Pi" → "the Beelink"), missed by the earlier Beelink migration docs pass
- Add `docs/adr/0004-shared-services-namespace.md`; update ADR 0001's consequences to record the deploy-bypass mechanism actually configured (was previously "not yet configured")

## Capabilities

### New Capabilities
- `hello-ci-pipeline`: CI behavior for `services/hello` — test gating on PRs, image build/tag/push to GHCR, and the Deploy commit that bumps the running tag
- `hello-deployment`: the Kubernetes-side contract for running `hello` — Application registration, namespace, replica/probe wiring, and image source

### Modified Capabilities
_(none — `hello-service`'s HTTP behavior is unchanged)_

## Impact

- `.github/workflows/ci.yml` — new `test-hello`, `build-push-hello`, `deploy-hello` jobs
- `deploy/apps/hello.yaml` (new), `deploy/services/hello/*` (new)
- GitHub ruleset on `main` — add `test-hello` to required status checks
- GitHub repo secret (deploy PAT), GHCR package visibility set to public
- `CONTEXT.md`, `docs/adr/0001-gitops-deploy-loop.md`, `docs/adr/0004-shared-services-namespace.md` (new)
