# Universal

A personal all-in-one Flutter app paired with self-hosted services on a Beelink SER5. The backend exists primarily as a learning vehicle for microservices, event-driven architecture, observability, and CI/CD.

## Language

### Platform

**Infra component**:
A piece of cluster infrastructure installed via its own ArgoCD Application under `deploy/infra/`, each in its own namespace — third-party, not authored by this project, and not a Service. Covers both long-running controllers (Sealed Secrets) and periodic jobs (the DuckDNS updater CronJob) — the distinguishing trait is "not a Service," not runtime shape. Configuring one you've already installed, without installing anything new, is Infra config instead. An Observability component is also third-party and not a Service, but isolation doesn't apply to it — see that entry.
_Avoid_: service (lowercase), controller (too narrow for the category), observability component (reserved for the shared-namespace stack)

**Observability component**:
A piece of the observability stack (otel-collector, Prometheus, Grafana, Loki, Tempo) — third-party and not a Service, like an Infra component, but sharing the single `observability` namespace with its siblings instead of getting one of its own (see ADR-0008: none of them holds privilege whose blast radius needs bounding, unlike Sealed Secrets). Its Application file lives under `deploy/apps/` like every workload's (see Root app); any local manifests it needs (rather than a pure remote Helm chart) would live under `deploy/observability/`, mirroring how an Infra component's local manifests live under `deploy/infra/`. Configuring one already installed, without installing anything new, is Observability config instead.
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

**App build**:
A GitHub Release CI publishes containing a signed APK artifact, triggered by a push to `main` touching `app/**`. Unrelated to a Deploy commit — nothing about the Beelink cluster changes when an App build is published; it exists purely so a device can download and install the app.
_Avoid_: release (ambiguous with Deploy commit's rejected alias), deploy

**Build Tag**:
The GitHub Release `tag_name` (e.g. `build-<timestamp>-<sha>`) identifying a specific App build, baked into the APK at CI build time so a running app knows which App build it is. Compared against GitHub's latest release tag to detect whether a newer App build exists.
_Avoid_: release tag, build identifier, version (no numeric versioning scheme exists)

**Update Check**:
The app's comparison, run on launch and again every time the Settings screen opens (no throttling), of its own Build Tag against GitHub's latest release Build Tag to decide whether a newer App build exists. Produces one of: checking, up to date, update available, or error.
_Avoid_: version check, build check

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

### Gym

**Workout**:
One visit to the gym, start to finish — the top-level thing a user logs. Carries a start timestamp and an end timestamp (date and time of day). When a Schedule is due, the app pre-creates a Workout with Exercise Entries and Sets pre-filled from the Routine's Planned Exercises, which the user then logs against (editing values as actually performed).
_Avoid_: session, workout session (session is overloaded — HTTP/auth sessions, this CLI's own sessions)

**Exercise**:
A reusable movement (e.g. "Bench Press"), created the first time a user types its name freeform and offered for reuse in later Workouts afterward. Not a predefined catalog — the user grows the list themselves.
_Avoid_: movement, lift

**Exercise Entry**:
One Exercise performed within a specific Workout — groups together the Sets logged for that Exercise in that Workout. A Workout has many Exercise Entries; an Exercise Entry references exactly one Exercise.
_Avoid_: exercise (reserved for the reusable movement definition), workout exercise

**Set**:
One performance of an Exercise Entry's Exercise at a given weight for a given rep count (e.g. "3 reps @ 50kg"), carrying its own logged-at timestamp (enables per-Exercise stats over time, independent of the Workout). `reps` is a plain attribute of a Set, not its own tracked entity. An Exercise Entry has many Sets, logged in order.
_Avoid_: rep (a rep is not tracked individually — it's a count on a Set)

**Routine**:
A named, reusable template (e.g. "Push Day") prescribing which Exercises to do and their target Sets/reps/weights — distinct from a Workout, which is the actual logged occurrence.
_Avoid_: plan (kept as the general idea of planning, not a concrete noun), program (reserved for an ordered sequence of Routines over a time period), template

**Program**:
An ordered sequence of Routines repeated over a specified time period (e.g. Push/Pull/Legs rotated across an 8-week block). Owns the Schedule that assigns Routines to occurrences — a Routine is never scheduled standalone.
_Avoid_: routine (a Program is composed of Routines, not the other way around), plan

**Schedule**:
The recurrence rule on a Program that determines when each Routine comes up next — either weekday-based (e.g. "Push on Mondays") or cadence-based (e.g. "every 3rd day," rolling regardless of weekday).
_Avoid_: recurrence (kept as the general concept; Schedule is the concrete noun for a Program's rule)

**Planned Exercise**:
The planned counterpart to an Exercise Entry — an Exercise prescribed within a Routine along with its target sets/reps/weights, before any Workout logs it.
_Avoid_: exercise entry (reserved for the logged occurrence within an actual Workout)

## Example dialogue

> **Dev:** The hello Service is built — how do I deploy it?
> **Expert:** You don't, directly. CI makes a Deploy commit and ArgoCD brings the Beelink in line with it. If it's not in git, it's not deployed.
> **Dev:** Can I add a Grafana dashboard while I'm at it?
> **Expert:** That's Phase 1. Phase 0 ends when the loop works, not when the cluster is fancy.

> **Dev:** I want today's push session to show up pre-filled.
> **Expert:** That's the Schedule on your Program firing — it pre-creates a Workout from the due Routine's Planned Exercises. You log against it, editing Sets as you actually perform them.
> **Dev:** Can I track my one-rep max as a stat?
> **Expert:** We punted on PRs — averages and trends are still open questions for stats-svc, not part of the core logging vocabulary yet.

> **Dev:** How does the app know it's out of date?
> **Expert:** Every App build carries a Build Tag baked in at CI time. The Update Check compares that against GitHub's latest release Build Tag — if they differ, an update's available.
> **Dev:** So it knows which one is newer?
> **Expert:** No — just "same" or "different." There's no ordering, only equality; see ADR-0013.
