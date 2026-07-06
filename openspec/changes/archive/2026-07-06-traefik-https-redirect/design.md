## Context

This is the last unchecked task of #13 (TLS via cert-manager + Let's Encrypt); cert-manager, the `letsencrypt-prod` `ClusterIssuer`, and hello's TLS-terminated ingress are all already live (#45/#46/#47, all closed). Per ADR-0006, this is the second tenant of `deploy/infra-config/` — ADR-0006 names "a HelmChartConfig patching k3s's bundled Traefik" as the literal reason that directory exists, since Traefik isn't something this repo installs (no `deploy/infra/traefik/` to nest config under). Unlike `letsencrypt-issuer`, this change has no dependency on, and nothing depends on it (per #48: "Independent of #45/#46/#47 — no dependency either way, can land in any order").

## Goals / Non-Goals

**Goals:**
- `http://xdezex.duckdns.org/hello` (and any future path/host on this Traefik) redirects to `https://` with a permanent redirect
- Redirect is host-wide, configured once on the entrypoint — new Ingresses don't need a per-resource annotation to get it
- Existing HTTP-01 challenge flow for `letsencrypt-prod` keeps working after the redirect is live

**Non-Goals:**
- Any change to `hello`'s Ingress, the `ClusterIssuer`, or cert-manager itself
- HSTS or other header-level hardening — out of scope for #48, which only asks for the redirect
- A staging rollout or feature flag — this is a single-host, single-operator cluster; the risk is blast radius on failure, not gradual rollout

## Decisions

**`HelmChartConfig` under `deploy/infra-config/traefik-redirect/`, not `deploy/infra/`.** Same reasoning as `letsencrypt-issuer`: this only patches an already-running, platform-provided controller (k3s's bundled Traefik), which ADR-0006 defines as Infra config rather than an Infra component this repo installs and owns the lifecycle of.

**Own ArgoCD Application, no `sync-wave` annotation.** Every other Application with a real ordering dependency carries a `sync-wave` (`cert-manager` at `"0"`, `letsencrypt-issuer` at `"1"`, waiting on cert-manager's webhook). `hello.yaml` carries none, because nothing orders against it. This change has no dependency in either direction, so it follows `hello.yaml`'s precedent rather than adding a wave annotation for its own sake.
_Alternative considered_: give it wave `"0"` anyway, on the theory that "foundational infra" should sync early. Rejected — sync-wave exists to encode actual ordering constraints; adding one that encodes no real dependency just implies a relationship that isn't there.

**`valuesContent` uses `ports.web.http.redirections.entryPoint` (`to: websecure`, `scheme: https`, `permanent: true`).** This is Traefik's own supported mechanism for an entrypoint-level redirect (as opposed to a per-Ingress `Middleware`/annotation), which is what makes it apply host-wide without touching `hello`'s or any future Ingress's manifest. (Initially written as `ports.web.redirections.entryPoint`, missing the `http` level — Helm silently ignored the unrecognized key rather than erroring, so the first deploy produced no actual redirect; fixed in #59 and confirmed against `traefik/traefik-helm-chart`'s `values.yaml`.)
_Alternative considered_: a Traefik `Middleware` CRD + `traefik.ingress.kubernetes.io/router.middlewares` annotation on each Ingress. Rejected — that's per-resource, so every new Ingress would need to remember to opt in, which is exactly what a "global" redirect (per #48's title) is meant to avoid.

**`HelmChartConfig` name/namespace (`traefik`/`kube-system`) match k3s's default bundled Traefik `HelmChart` exactly.** k3s's helm-controller only merges a `HelmChartConfig` into a `HelmChart` release with the identical name and namespace; this hasn't been overridden anywhere else in this repo, so the defaults apply.

## Risks / Trade-offs

- **[Risk]** Traefik is the only ingress controller on this host — a malformed `valuesContent` (wrong entrypoint name, bad YAML) could break every Ingress simultaneously, not just `hello`, unlike every prior change in this repo which was purely additive → **Mitigation**: keep the patch to the single documented `redirections` stanza; verify with `ssh miniser` (`sudo kubectl get pods -n kube-system -l app.kubernetes.io/name=traefik` and a plain `curl -I` against both ports) immediately after sync, before considering this done.
- **[Risk]** The redirect changes port-80 behavior site-wide, which is also the path cert-manager's HTTP-01 solver uses for `letsencrypt-prod` (per the `letsencrypt-issuer` spec's ACME requirement) → **Mitigation**: ACME validators follow HTTPS redirects per the ACME spec, so this should be transparent, but verify explicitly post-deploy rather than assuming — either watch a real renewal or, at minimum, confirm the solver's temporary Ingress still resolves through Traefik with the redirect active.
- **[Risk]** ArgoCD's own reachability if this somehow breaks Traefik → **Mitigation**: confirmed via `deploy/bootstrap/argocd-install.yaml` that `argocd-server` is a plain `ClusterIP` Service with no Ingress in front of it, so a broken Traefik doesn't lock out ArgoCD access (still reachable via `kubectl`/port-forward on the host).

## Migration Plan

1. Add `deploy/infra-config/traefik-redirect/kustomization.yaml` and `helmchartconfig.yaml` (the `traefik`/`kube-system` `HelmChartConfig` with the `redirections` `valuesContent`).
2. Add `deploy/apps/traefik-redirect.yaml` (git-sourced Application, no sync-wave, path `deploy/infra-config/traefik-redirect/`, destination namespace `kube-system`).
3. Commit, merge, let ArgoCD sync.
4. Verify via `ssh miniser`: Traefik pod(s) in `kube-system` still healthy; `curl -I http://xdezex.duckdns.org/hello` returns a redirect to `https://`; `curl -I https://xdezex.duckdns.org/hello` still succeeds.
5. Verify the ACME path isn't broken: check `letsencrypt-prod`'s existing `Certificate` status is still `Ready: True` post-sync (a renewal isn't due immediately, but a healthy status now plus the redirect being a standards-following HTTPS redirect is the available evidence short of waiting for the next real renewal).
6. Rollback: delete the `traefik-redirect` Application (or revert the commit and let `selfHeal` prune it). k3s's helm-controller removes the `HelmChartConfig` override and the bundled Traefik release reverts to its unpatched defaults on the next reconcile — nothing else in the cluster references this config.

## Open Questions

None outstanding — placement, redirect mechanism, and sync-wave were resolved during exploration before this proposal was written.
