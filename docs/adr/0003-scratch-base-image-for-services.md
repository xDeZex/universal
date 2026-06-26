# scratch runtime image for Go Service containers

Go Services have no runtime dependencies beyond the static binary itself, so we use `scratch` as the base image for the runtime stage in every Service's multi-stage Dockerfile. This gives the smallest possible image and the smallest attack surface: no shell, no package manager, no OS utilities.

`distroless/static:nonroot` was considered — it adds a non-root user and CA certificates without adding a shell. Rejected because: (1) Services make no outbound TLS calls, so CA certs are unused; (2) `scratch` supports numeric `USER` instructions (`USER 65534:65534`) without a passwd database, so non-root is enforced in the image itself; (3) the extra layer adds an external dependency (Google's registry) with no benefit at this stage.

`alpine` was rejected for the same reasons plus the presence of a shell, which is the main thing we want to avoid.

## Consequences

- `kubectl exec` into a running pod is not possible — there is no shell to exec. Debugging must go through logs (`kubectl logs`) or the Health and Root endpoints.
- If a future Service makes outbound TLS calls, its Dockerfile must switch to `distroless/static` or bundle CA certs explicitly.
