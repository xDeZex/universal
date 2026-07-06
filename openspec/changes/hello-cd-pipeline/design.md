## Context

`services/hello` has a Dockerfile but nothing deploys it: `deploy/apps/` is empty (just `.gitkeep`), there's no CI job that builds/pushes/tests it, and `main`'s ruleset requires a PR for every change with no bypass configured for an automated identity (ADR 0001 flagged this as unresolved Phase 0 work). This change closes that gap end-to-end: test gate → build/push → Deploy commit → ArgoCD-managed workload, following the app-of-apps and namespace decisions worked out during scoping (see `docs/adr/0004-shared-services-namespace.md` and the updated ADR 0001).

## Goals / Non-Goals

**Goals:**
- First image build/push/deploy pipeline for a Go Service, reusable in shape for future Services
- First real ArgoCD-managed workload, establishing the `deploy/apps/<app>.yaml` + `deploy/services/<app>/` pattern
- Close the untested-CI gap before anything gets built and deployed automatically

**Non-Goals:**
- External exposure / ingress / TLS (issues #10, #13) — this change only gets `hello` running and reachable *inside* the cluster
- Observability, resource tuning (Phase 1) — no requests/limits are set; revisit once there's real usage data
- Sealed Secrets rollout (#12) — not needed here since the GHCR package is public and the deploy PAT is a plain GitHub repo secret, not an in-cluster Secret

## Decisions

**App-of-apps split** (`deploy/apps/hello.yaml` + `deploy/services/hello/`). Alternative considered: let the root app recurse directly over per-service subdirectories under `deploy/apps/`. Rejected — it contradicts what CONTEXT.md and `deploy/CLAUDE.md` already say `deploy/apps/` is for (Application files only), and `root-app.yaml` has no `directory.recurse` set.

**Shared `services` namespace**, not per-service. Alternative: one namespace per Service (the more idiomatic k8s default). Rejected for now — single-node, single-operator cluster, isolation doesn't pay for itself yet. Recorded as `docs/adr/0004`.

**`deploy/services/hello/`**, not `deploy/hello/`. Alternative: flat, one directory per service directly under `deploy/`. Rejected — grouping under `services/` keeps `deploy/`'s top level to three self-explanatory directories as more Services are added in Phase 2/3.

**Image tag = short git SHA**, matching the `-ldflags`-baked `version` string. Alternative: full 40-char SHA for stronger collision resistance. Rejected — this project already committed to short SHA as the version format (`hello-service` spec, `Root endpoint` term); a mismatched tag/version would be confusing for no real benefit at this scale.

**Deploy commits authored as `github-actions[bot]`**, message `deploy: hello@<short-sha>`. Alternative: author as the repo owner (since the PAT belongs to that account). Rejected — would make automated Deploy commits indistinguishable from human commits in `git log`.

**`test-hello` added as a required status check.** Without it, the new build/deploy pipeline would build and ship an image whose tests never ran. This is a pre-existing gap (from #8, not #9), but this change is the first thing that actually depends on `services/hello` being tested, so it's the natural point to close it.

**Deploy PAT rides the existing admin ruleset bypass rather than a new bot bypass actor.** Already decided in ADR 0001; this change is what actually configures it — see the updated Consequences section there.

**GHCR package public, no `imagePullSecret`.** Alternative: private package + Sealed Secret. Rejected — `hello` has nothing sensitive in it, and a private package would mean sealing and rotating a pull-secret for a placeholder Service. Revisit per-Service if a later Service does need a private image.

**Extend `lint-deploy`'s `kubeconform` step to also validate `deploy/services/hello`.** Currently `ci.yml` only runs `kustomize build deploy/bootstrap` through `kubeconform` — the new manifests under `deploy/apps/` and `deploy/services/hello/` wouldn't be schema-validated at all otherwise, despite `lint-deploy` nominally covering `deploy/**`.

## Risks / Trade-offs

- **[Risk]** The deploy PAT is scoped to this repo (`contents: write` only) but rides the account's admin-level ruleset bypass — if leaked, it grants direct write access to `main`. → **Mitigation**: fine-grained scope limits blast radius to this repo; store only as a GitHub Actions secret, never logged; rotate if ever exposed.
- **[Risk]** A shared `services` namespace means one Service's bug (e.g. a NetworkPolicy misconfiguration, resource hog) can affect others sharing the namespace. → **Mitigation**: explicit, documented trade-off (ADR 0004); revisit before Phase 2's event-driven services or before adding other users.
- **[Risk]** The Deploy commit pushes to `main`, which re-triggers the same CI workflow (a `deploy/` change re-runs `lint-deploy`, but not `build-push-hello` since that's gated on `services/hello/**`). → **Mitigation**: no infinite loop, since the two path filters don't overlap; the extra `lint-deploy` run is cheap and idempotent, not worth `[skip ci]` complexity.
- **[Risk]** No resource requests/limits on the Deployment — a runaway process could affect the single-node cluster. → **Mitigation**: acceptable for a hello-world learning service today; revisit once Phase 1 observability gives real data to size against.
- **[Risk]** First-ever tag in `deploy/services/hello/kustomization.yaml` needs to reference a real, already-pushed image before ArgoCD can sync successfully — see Migration Plan.

## Migration Plan

1. Merge the CI workflow changes (`test-hello`, `build-push-hello`, `deploy-hello` jobs) and the extended `lint-deploy` validation.
2. Add the repo secret for the deploy PAT (e.g. `DEPLOY_TOKEN`) and set the GHCR package for `hello` to public once it exists.
3. Land `deploy/apps/hello.yaml` and `deploy/services/hello/*` in the same PR as a trivial `services/hello` touch (or immediately followed by one) — this guarantees the merge-to-main push triggers `build-push-hello` and `deploy-hello`, so the very first image tag is populated by the pipeline itself rather than hand-edited into `kustomization.yaml`. Bootstrapping a placeholder tag by hand and hoping the next real change fixes it is unnecessary if we just ensure this PR includes one.
4. Confirm ArgoCD syncs `hello` into the new `services` namespace, pods go Ready, and `kubectl -n services port-forward` (or similar) confirms `/` and `/healthz` respond as the `hello-service` spec describes.

No rollback beyond the usual `git revert` of the Deploy commit (ADR 0001's model) — reverting bumps the tag back to the prior SHA and ArgoCD self-heals to match.

## Open Questions

- Add `workflow_dispatch` to the build/push job for manual re-triggering without a `services/hello` code change? Not required for this change's scope; worth considering if rebuilding-without-a-diff becomes a recurring need.
