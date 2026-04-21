# Secret Management Strategy

## Overview

This platform uses Kubernetes native secrets with the following security controls:

- Secrets are encrypted at rest in etcd
- RBAC restricts secret access to authorized service accounts
- Secrets are mounted as volumes or environment variables, never logged
- External Secrets Operator can be added for integration with AWS Secrets Manager

## Current Approach

Application teams reference secrets in their Helm values:

```yaml
env:
  - name: DATABASE_PASSWORD
    valueFrom:
      secretKeyRef:
        name: app-secrets
        key: db-password
```

## Creating Secrets

For development:
```bash
kubectl create secret generic app-secrets \
  --from-literal=db-password=changeme \
  -n dev
```

For production, use sealed-secrets or external-secrets-operator.

## Future Enhancement: External Secrets Operator

To integrate with AWS Secrets Manager:

1. Install External Secrets Operator via Argo CD
2. Configure IRSA for the operator
3. Create SecretStore and ExternalSecret resources

Example:
```yaml
apiVersion: external-secrets.io/v1beta1
kind: SecretStore
metadata:
  name: aws-secrets
  namespace: prod
spec:
  provider:
    aws:
      service: SecretsManager
      region: eu-north-1
      auth:
        jwt:
          serviceAccountRef:
            name: external-secrets
---
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: app-secrets
  namespace: prod
spec:
  refreshInterval: 1h
  secretStoreRef:
    name: aws-secrets
    kind: SecretStore
  target:
    name: app-secrets
  data:
    - secretKey: db-password
      remoteRef:
        key: prod/app/db-password
```

## Best Practices

- Never commit secrets to Git
- Use different secrets per environment
- Rotate secrets regularly
- Limit secret access with RBAC
- Use workload identity (IRSA) instead of long-lived credentials
