## Why

Phase 0 requires a running workload on the Pi to validate the GitOps loop end-to-end. The hello service is the simplest possible Service — an HTTP server that proves the build → push → ArgoCD sync → k3s run pipeline works.

## What Changes

- New `services/hello/` directory with a minimal Go HTTP server
- New multi-stage Dockerfile producing a static linux/arm64 image (distroless/static:nonroot)
- Kubernetes manifests (`deploy/apps/hello/`) move to issue #9 alongside CI

## Capabilities

### New Capabilities

- `hello-service`: HTTP server exposing `GET /` (JSON identity + version) and `GET /healthz` (liveness probe) on port 8080

### Modified Capabilities

## Impact

- Creates `services/hello/` (new Go module)
- No changes to Flutter app, existing manifests, or `deploy/`
