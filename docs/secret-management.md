# Secret Management

External Secrets Operator manages secret synchronization from a central store into Kubernetes Secrets.

## Architecture

```
platform-secrets/namespace          dev/stage/prod namespaces
  ┌──────────────┐                   ┌──────────────────┐
  │ Secret       │ ← ExternalSecret →│ Secret           │
  │ (source)     │   syncs to env    │ (consumed by pod)│
  └──────────────┘                   └──────────────────┘
         ↑
  ClusterSecretStore
  (kubernetes provider for local dev)
```

## How it works

1. **External Secrets Operator** is installed as an Argo CD add-on (`platform/addons/external-secrets.yaml`)
2. A **ClusterSecretStore** defines the backend — `kubernetes` provider for local dev (no cloud creds needed). Swap to `aws`/`gcp`/`azure` provider in production
3. The Helm chart includes an **ExternalSecret template** that creates a Kubernetes Secret from the store
4. The app's Deployment references the resulting Secret via `env[].valueFrom.secretKeyRef`

## Per-environment setup

Secrets are stored in the `platform-secrets` namespace and pulled into each environment namespace by ExternalSecret:

```yaml
# In platform/apps/dev/values.yaml
externalSecret:
  enabled: true
  data:
    - secretKey: db-password
      remoteRef:
        key: dev/simple-app/db-password
```

## Local dev

The Makefile seeds a dev secret automatically:

```bash
kubectl create secret generic dev-simple-app-db-password \
  --from-literal=db-password=local-dev-password \
  -n platform-secrets
```

## Production migration

| Provider | ClusterSecretStore change |
|---|---|
| AWS Secrets Manager | Change `provider.kubernetes` → `provider.aws` + configure IRSA |
| GCP Secret Manager | Change `provider.kubernetes` → `provider.gcp` + configure Workload Identity |
| HashiCorp Vault | Use `provider.vault` with Kubernetes auth |

## Best practices

- Never commit raw secrets to Git
- Use different secret keys per environment
- Set `refreshInterval` to match your rotation policy
- Restrict store access with RBAC
