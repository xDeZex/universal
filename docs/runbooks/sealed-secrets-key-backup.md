# Sealed Secrets controller key backup

The Sealed Secrets controller's private key lives only in the cluster (`sealed-secrets` namespace) — it is never committed to git. If the cluster is rebuilt without this backup, every SealedSecret in `deploy/` must be re-sealed from scratch against a new key.

Redo this procedure whenever the controller is installed or its key is rotated.

## Procedure

1. Export the active key from the cluster:
   ```
   kubectl get secret -n sealed-secrets -l sealedsecrets.bitnami.com/sealed-secrets-key -o yaml > sealed-secrets-key-backup.yaml
   ```
2. Encrypt it locally with `age` (never upload the plaintext):
   ```
   age -e -r <your-age-public-key> sealed-secrets-key-backup.yaml > sealed-secrets-key-backup.yaml.age
   ```
3. Email `sealed-secrets-key-backup.yaml.age` as an attachment to yourself (ollibolli.lillberg@gmail.com).
4. Delete both local files (`sealed-secrets-key-backup.yaml` and the `.age` file) once the email is sent.

## Restore

1. Find the email, download the attachment.
2. Decrypt: `age -d sealed-secrets-key-backup.yaml.age > sealed-secrets-key-backup.yaml`
3. Apply it before the controller starts for the first time on the rebuilt cluster: `kubectl apply -f sealed-secrets-key-backup.yaml`
4. Delete the local plaintext file.
