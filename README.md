# Universal

A personal all-in-one app, and a playground for learning backend infrastructure.

Two halves:

- **Flutter app** — checklist today, gym session tracking (sets, reps, weights) coming.
- **Backend on a Raspberry Pi** — Go services on k3s, deployed via GitOps, built to learn microservices, event-driven architecture, observability, and CI/CD.

## Roadmap

Tracked in [issues](../../issues), starting with the [Phase 0 epic](../../issues/11).

| Phase | Goal |
|-------|------|
| 0 | Hello world on the Pi: k3s + ArgoCD, `git push` → live on the Pi |
| 1 | Observability: metrics, logs, dashboards |
| 2 | Event-driven services: NATS JetStream, workout → stats events |
| 3 | Flutter gym-tracking UI talking to the backend |

## Architecture

```
Flutter app (phone)
      │
      ▼
Raspberry Pi 4B (DietPi, arm64, 4GB)
└── k3s
    ├── Traefik (ingress, port-forwarded)
    ├── ArgoCD (core) ── watches deploy/ on main
    └── services (Go, images on GHCR)
```

Target CI/CD loop (Phase 0, in progress): push to `main` → GitHub Actions builds a linux/arm64 image to GHCR → image tag bumped in `deploy/` → ArgoCD syncs the cluster.

## Repo layout

```
lib/         Flutter app
test/        Flutter tests
services/    Go backend services, one dir per service (planned, Phase 0)
deploy/      Kubernetes manifests, synced by ArgoCD (planned, Phase 0)
```

## App features

- Checklist with drag-and-drop reordering
- Dark mode support
- Auto-save with local storage

## Download

Get the latest APK from the [Releases](../../releases) page.

## Build Setup

### APK Signing

I know this is unsafe, I just want it to be easy. No one except me is using this app.

1. **Generate a keystore**:
   ```powershell
   keytool -genkey -v -keystore android/app/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```

2. **Update `android/key.properties`** with your password:
   ```properties
   storePassword=YOUR_PASSWORD
   keyPassword=YOUR_PASSWORD
   keyAlias=upload
   storeFile=upload-keystore.jks
   ```

3. **Commit both files** to the repo
