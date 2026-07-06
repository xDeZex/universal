## 1. Docs cleanup (scoping decisions already captured)

- [x] 1.1 Fix stale `CONTEXT.md:37` dialogue line ("the Pi" → "the Beelink")
- [x] 1.2 Add `Services namespace` term to `CONTEXT.md`
- [x] 1.3 Add `docs/adr/0004-shared-services-namespace.md`
- [x] 1.4 Update ADR 0001's consequences to reflect the configured deploy-bypass mechanism

## 2. CI: Go test gate for services/hello

- [x] 2.1 Add a `test-hello` job running `go test ./...` and `go vet ./...` for `services/hello`, gated on `services/**` changes
- [ ] 2.2 Add `test-hello` to `main`'s ruleset required status checks

## 3. CI: build and push the hello image

- [x] 3.1 Add a `build-push-hello` job: build `linux/amd64` from `services/hello/Dockerfile` on push to `main` touching `services/hello/**`
- [x] 3.2 Tag and push the image to `ghcr.io/xdezex/universal/hello` using the short git SHA, passed as both the GHCR tag and the `VERSION` build-arg
- [ ] 3.3 Set the `ghcr.io/xdezex/universal/hello` package visibility to public once it exists

## 4. CI: Deploy commit

- [ ] 4.1 Add a repo secret (e.g. `DEPLOY_TOKEN`) holding the fine-grained PAT (`contents: write` only)
- [x] 4.2 Add a `deploy-hello` job: after a successful build/push, bump the image tag in `deploy/services/hello/kustomization.yaml` and commit to `main` as `github-actions[bot]`, message `deploy: hello@<short-sha>`, authenticating the push with `DEPLOY_TOKEN`

## 5. Kubernetes manifests for hello

- [x] 5.1 Add `deploy/apps/hello.yaml` — ArgoCD `Application` sourcing `deploy/services/hello`, targeting the `services` namespace, automated sync (`prune` + `selfHeal`), `CreateNamespace=true`
- [x] 5.2 Add `deploy/services/hello/kustomization.yaml`, `deployment.yaml` (1 replica, liveness + readiness probes on `GET /healthz:8080`, no `imagePullSecrets`), `service.yaml` (ClusterIP, port 8080)
- [x] 5.3 Extend `lint-deploy`'s `kubeconform` step to also `kustomize build` + validate `deploy/services/hello` (currently only `deploy/bootstrap` is validated)

## 6. Verify end-to-end

- [ ] 6.1 Confirm the first merge to `main` (including a trivial `services/hello` touch) triggers `test-hello` → `build-push-hello` → `deploy-hello` in order, and the resulting Deploy commit's tag matches what was pushed to GHCR
- [ ] 6.2 Confirm ArgoCD syncs the `hello` Application, the `services` namespace is created, and the pod goes Ready
- [ ] 6.3 Confirm in-cluster `GET /` and `GET /healthz` against the hello Service respond as the `hello-service` spec describes, with `version` matching the deployed tag
