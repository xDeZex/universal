## 1. Traefik redirect is deployed as its own git-sourced Application

- [x] 1.1 `deploy/infra-config/traefik-redirect/kustomization.yaml` lists the `HelmChartConfig` manifest
- [x] 1.2 `deploy/infra-config/traefik-redirect/helmchartconfig.yaml` defines a `HelmChartConfig` named `traefik` in namespace `kube-system`
- [x] 1.3 `deploy/apps/traefik-redirect.yaml` is a git-sourced ArgoCD Application (path `deploy/infra-config/traefik-redirect/`, destination namespace `kube-system`, no `sync-wave` annotation), synced automatically with `prune: true` / `selfHeal: true`

## 2. HTTP requests on the web entrypoint are redirected to HTTPS

- [x] 2.1 `helmchartconfig.yaml`'s `valuesContent` configures `ports.web.redirections.entryPoint` with `to: websecure`, `scheme: https`, `permanent: true`
- [ ] 2.2 After sync, `ssh miniser` + `curl -I http://xdezex.duckdns.org/hello` returns a redirect to `https://xdezex.duckdns.org/hello`
- [ ] 2.3 `curl -I https://xdezex.duckdns.org/hello` still succeeds after the redirect is live (existing TLS path unaffected)
- [ ] 2.4 `letsencrypt-prod`'s `Certificate` for `xdezex.duckdns.org` still reports `Ready: True` after sync (ACME/HTTP-01 path not broken by the redirect)
