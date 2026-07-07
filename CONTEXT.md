# Universal

A personal all-in-one Flutter app paired with self-hosted services on a Beelink SER5. The backend exists primarily as a learning vehicle for microservices, event-driven architecture, observability, and CI/CD.

## Language

**Infra component**:
A piece of cluster infrastructure installed via its own ArgoCD Application under `deploy/infra/`, each in its own namespace — third-party, not authored by this project, and not a Service. Covers both long-running controllers (Sealed Secrets) and periodic jobs (the DuckDNS updater CronJob) — the distinguishing trait is "not a Service," not runtime shape. Configuring one you've already installed, without installing anything new, is Infra config instead. An Observability component is also third-party and not a Service, but isolation doesn't apply to it — see that entry.
_Avoid_: service (lowercase), controller (too narrow for the category), observability component (reserved for the shared-namespace stack)

**Observability component**:
A piece of the observability stack (otel-collector, Prometheus, Grafana, Loki, later a traces backend) — third-party and not a Service, like an Infra component, but sharing the single `observability` namespace with its siblings instead of getting one of its own (see ADR-0008: none of them holds privilege whose blast radius needs bounding, unlike Sealed Secrets). Its Application file lives under `deploy/apps/` like every workload's (see Root app); any local manifests it needs (rather than a pure remote Helm chart) would live under `deploy/observability/`, mirroring how an Infra component's local manifests live under `deploy/infra/`. Configuring one already installed, without installing anything new, is Observability config instead.
_Avoid_: infra component (reserved for per-component namespace isolation), observability config (reserved for authored config, no new install)

**Observability namespace**:
The single Kubernetes namespace (`observability`) every Observability component runs in. One shared namespace across all of them, not one per component — mirrors the Services namespace's reasoning: no component here holds privilege whose blast radius needs bounding, and they're mutually interdependent by design (see ADR-0008).
_Avoid_: infra namespace, per-component namespace

**Infra config**:
A manifest we author that configures an existing Infra component or a platform-provided controller (e.g. k3s's bundled Traefik) with cluster-wide, general-purpose applicability — no new software is installed. Lives under `deploy/infra-config/`, a sibling of `deploy/infra/`, each still with its own ArgoCD Application under `deploy/apps/`. Distinguishes "we wrote this YAML" from "we installed this third-party program." Authored config narrowly scoped to the observability stack, rather than the whole cluster, is Observability config instead — even when it happens to configure the same kind of platform-provided controller.
_Avoid_: infra component (reserved for installed third-party software), config, patch, observability config (reserved for config scoped to the observability stack)

**Observability config**:
A manifest we author that configures a platform-provided controller or an already-installed Observability component, scoped to the observability stack rather than the whole cluster — no new software is installed. Mirrors Infra config's shape (authored YAML, not an install) but lives under `deploy/observability-config/`, a sibling of `deploy/observability/`, keeping the observability stack self-contained and independent of the production app's own infra. Each still gets its own ArgoCD Application under `deploy/apps/`.
_Avoid_: infra config (reserved for cluster-wide, general-purpose authored config), observability component (reserved for installed third-party software)

**Service**:
An independently deployable Go backend program with its own directory under `services/`, its own container image, and its own manifests. The app is not a Service; it is the client.
_Avoid_: microservice, server, backend (for a single one)

**Services namespace**:
The single Kubernetes namespace (`services`) every Service runs in. One shared namespace across all Services, not one per Service — the cluster is single-node, single-operator, so per-Service isolation doesn't pay for itself yet; revisit if that changes.
_Avoid_: default namespace, per-service namespace

**Deploy commit**:
A CI-authored commit to `main` that changes which image version the cluster should run. A Deploy commit is the deploy — nothing else changes what runs on the Beelink.
_Avoid_: release, push to prod

**External host**:
The single DNS name (`xdezex.duckdns.org`) every Service is reachable under, routed by path per Service rather than one host per Service. TLS for this host is shared across every Service's Ingress (see ADR-0007), not issued per-Service.
_Avoid_: per-service domain, subdomain-per-service

**Phase**:
A numbered rung of the learning roadmap (0: GitOps loop, 1: observability, 2: events, 3: gym UI). Phases gate scope: work belonging to a later Phase is out of scope by default.

**Root app**:
The single ArgoCD Application installed during Bootstrap that watches `deploy/apps/` on `main`. Every workload is an Application file in `deploy/apps/`; the root app syncs them all. It is the only ArgoCD object that is never committed to `deploy/apps/` itself.
_Avoid_: app-of-apps, parent app

**Bootstrap**:
The one-time `kubectl apply -k deploy/bootstrap/` that installs ArgoCD and the root Application on a fresh cluster. After Bootstrap, the cluster is self-managing; no further kubectl is needed to deploy workloads.
_Avoid_: setup, install, init

**Health endpoint**:
`GET /healthz` on every Service — returns HTTP 200 with no body. Used by k8s liveness/readiness probes.
_Avoid_: /health, /ping, /status

**Root endpoint**:
`GET /` on every Service — returns JSON `{"service":"<name>","version":"<git-sha>"}`. Version is the short git commit SHA baked in at build time via `ldflags`.
_Avoid_: returning plain text, hardcoded version strings

## Example dialogue

> **Dev:** The hello Service is built — how do I deploy it?
> **Expert:** You don't, directly. CI makes a Deploy commit and ArgoCD brings the Beelink in line with it. If it's not in git, it's not deployed.
> **Dev:** Can I add a Grafana dashboard while I'm at it?
> **Expert:** That's Phase 1. Phase 0 ends when the loop works, not when the cluster is fancy.
