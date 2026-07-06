# Infra config as a category distinct from Infra component

We split "Infra component" (third-party software we install, e.g. cert-manager, Sealed Secrets) from a new term, "Infra config" (manifests we author to configure an existing Infra component or a platform-provided controller, e.g. a cert-manager ClusterIssuer or a HelmChartConfig patching k3s's bundled Traefik). Infra config manifests live in a new sibling directory, `deploy/infra-config/`, rather than nested under the component they configure, because some Infra config (the Traefik redirect) configures a controller that isn't an Infra component at all — there's no `deploy/infra/` entry to nest it under. Each Infra config still gets its own ArgoCD Application under `deploy/apps/`, same as an Infra component, so sync-wave ordering (e.g. a ClusterIssuer waiting on cert-manager's CRDs and webhook) works the same way.

## Considered options

- **Nest config under the component it configures** (e.g. `deploy/infra/cert-manager/issuer/`) — rejected: doesn't generalize to config for controllers we didn't install ourselves, like k3s's built-in Traefik.
