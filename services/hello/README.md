# hello

Minimal Go HTTP service used to establish the first end-to-end CI/CD and
GitOps pipeline in this repo (see `docs/adr/0001-gitops-deploy-loop.md`,
`docs/adr/0004-shared-services-namespace.md`).

## Endpoints

- `GET /` — returns `{"service":"hello","version":"<short-git-sha>"}`
- `GET /healthz` — returns `200` with an empty body

`version` is baked in at build time via `-ldflags -X main.version=...` and
matches the image tag pushed to `ghcr.io/xdezex/universal/hello`.
