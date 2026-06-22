# Universal

A personal all-in-one Flutter app paired with self-hosted services on a Raspberry Pi. The backend exists primarily as a learning vehicle for microservices, event-driven architecture, observability, and CI/CD.

## Language

**Service**:
An independently deployable Go backend program with its own directory under `services/`, its own container image, and its own manifests. The app is not a Service; it is the client.
_Avoid_: microservice, server, backend (for a single one)

**Deploy commit**:
A CI-authored commit to `main` that changes which image version the cluster should run. A Deploy commit is the deploy — nothing else changes what runs on the Pi.
_Avoid_: release, push to prod

**Phase**:
A numbered rung of the learning roadmap (0: GitOps loop, 1: observability, 2: events, 3: gym UI). Phases gate scope: work belonging to a later Phase is out of scope by default.

**Root app**:
The single ArgoCD Application installed during Bootstrap that watches `deploy/apps/` on `main`. Every workload is an Application file in `deploy/apps/`; the root app syncs them all. It is the only ArgoCD object that is never committed to `deploy/apps/` itself.
_Avoid_: app-of-apps, parent app

**Bootstrap**:
The one-time `kubectl apply -k deploy/bootstrap/` that installs ArgoCD and the root Application on a fresh cluster. After Bootstrap, the cluster is self-managing; no further kubectl is needed to deploy workloads.
_Avoid_: setup, install, init

## Example dialogue

> **Dev:** The hello Service is built — how do I deploy it?
> **Expert:** You don't, directly. CI makes a Deploy commit and ArgoCD brings the Pi in line with it. If it's not in git, it's not deployed.
> **Dev:** Can I add a Grafana dashboard while I'm at it?
> **Expert:** That's Phase 1. Phase 0 ends when the loop works, not when the cluster is fancy.
