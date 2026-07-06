## ADDED Requirements

### Requirement: hello is registered as an ArgoCD Application

`deploy/apps/hello.yaml` SHALL define an ArgoCD `Application` named `hello`, sourcing `deploy/services/hello`, targeting the `services` namespace, with automated sync (`prune` + `selfHeal`) consistent with the root app's policy, and `CreateNamespace=true` so the `services` namespace is created automatically.

#### Scenario: Happy path — root app syncs hello

- **WHEN** the root app syncs `deploy/apps/`
- **THEN** ArgoCD creates/reconciles the `hello` Application, which syncs `deploy/services/hello` into the `services` namespace

#### Scenario: Error/rejection — invalid manifests

- **WHEN** `deploy/services/hello/kustomization.yaml` or its resources are invalid
- **THEN** the `hello` Application reports an `OutOfSync`/error state rather than partially applying

#### Scenario: Contract — namespace created automatically

- **WHEN** the `services` namespace does not yet exist in the cluster
- **THEN** ArgoCD creates it as part of syncing the `hello` Application, requiring no manual `kubectl` step

---

### Requirement: hello Deployment runs with health probes wired to `/healthz`

`deploy/services/hello/deployment.yaml` SHALL run 1 replica of the `hello` image in the `services` namespace, with liveness and readiness probes both targeting `GET /healthz` on port 8080.

#### Scenario: Happy path — pod becomes ready

- **WHEN** the hello pod starts and `/healthz` responds 200
- **THEN** the readiness probe marks the pod Ready and the liveness probe keeps it running

#### Scenario: Error/rejection — health check fails

- **WHEN** `/healthz` stops responding (e.g. the process is hung)
- **THEN** the liveness probe fails repeatedly and kubelet restarts the container

---

### Requirement: hello is reachable via a ClusterIP Service

`deploy/services/hello/service.yaml` SHALL expose the hello Deployment as a ClusterIP Service on port 8080 in the `services` namespace, selecting pods by the Deployment's labels.

#### Scenario: Happy path — in-cluster reachability

- **WHEN** another pod in the cluster requests `http://hello.services.svc.cluster.local:8080/`
- **THEN** it receives the hello Service's root endpoint response

#### Scenario: Error/rejection — selector mismatch

- **WHEN** the Service's selector does not match the Deployment's pod labels
- **THEN** the Service has no endpoints and requests to it fail to connect

---

### Requirement: hello image is pulled without an `imagePullSecret`

The Deployment SHALL reference `ghcr.io/xdezex/universal/hello:<sha>` directly with no `imagePullSecrets`, relying on the GHCR package's public visibility.

#### Scenario: Happy path — anonymous pull succeeds

- **WHEN** kubelet pulls `ghcr.io/xdezex/universal/hello:<sha>`
- **THEN** the pull succeeds with no registry credentials configured

#### Scenario: Error/rejection — package made private

- **WHEN** the GHCR package's visibility is ever changed to private
- **THEN** image pulls fail with `ImagePullBackOff`, since no pull secret is configured for this Deployment

#### Scenario: Contract — no auth header sent

- **WHEN** kubelet requests the image manifest from GHCR
- **THEN** no authentication header is sent, consistent with the package being public
