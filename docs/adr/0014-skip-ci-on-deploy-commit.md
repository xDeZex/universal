# Mark the Deploy commit `[skip ci]` to prevent a trigger loop

`ci-hello.yml` triggers on push to `deploy/services/hello/**`, and its own `deploy-hello` job pushes a Deploy commit to that same path — so each Deploy commit re-ran the whole build/push/deploy pipeline with a new SHA, producing another Deploy commit, indefinitely (a Trigger loop, distinct from the intentional GitOps deploy loop in ADR-0001). We decided: append `[skip ci]` to the Deploy commit's message, which GitHub Actions natively honors to skip push/PR triggers for that commit.

## Considered options

- **Exclude `deploy/services/hello/**` from the `push` trigger's `paths`** (mirroring `ci-deploy.yml`'s `'!deploy/services/hello/**'`) — rejected: it would also silently skip CI for a manual, non-bot edit to that path on `main`.
- **Guard every job with `if: github.event.head_commit.author.name != 'github-actions[bot]'`** — rejected: more verbose, duplicated across every job in the workflow, for the same effect `[skip ci]` gives for free.

## Consequences

- The Deploy commit's manifest is not re-validated by `validate-hello-manifests` after the commit lands — but it was already validated in the same push's run that produced it, before `deploy-hello` bumped the tag, so nothing goes unchecked.
- `[skip ci]` is a magic string with no enforcement; if a future edit to `deploy-hello`'s commit step drops it, the Trigger loop returns silently (visible only as a growing chain of Deploy commits and consumed CI minutes).
