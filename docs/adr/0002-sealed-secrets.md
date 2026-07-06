# Sealed Secrets for cluster secrets in a public repo

ADR 0001 makes git the only way into the cluster, but this repo is public, so plaintext Kubernetes Secrets can never be committed. We decided to run the Bitnami Sealed Secrets controller: secrets are encrypted locally with the controller's public key (`kubeseal`), the resulting SealedSecret YAML is committed and synced by ArgoCD like any other manifest, and only the in-cluster controller can decrypt it. This keeps the everything-in-git rule intact even for secrets (first user: the DuckDNS updater token).

**Caveat:** the controller's private key is the one piece of state that lives only in the cluster — back it up off the Beelink (see `docs/runbooks/sealed-secrets-key-backup.md`), or accept re-sealing every secret after a cluster rebuild.

## Considered options

- **Hand-applied secrets** (`kubectl create secret` over SSH) — rejected: cluster state silently diverges from git and the exception grows with every new secret (Phase 2+ adds DB credentials etc.).
- **SOPS + age** — rejected: first-class in Flux, but needs a plugin sidecar with ArgoCD core; weakest fit for this stack.
