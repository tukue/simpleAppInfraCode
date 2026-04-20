# Platform Operations

## Bootstrap Sequence

1. Provision AWS infrastructure from `infra/`.
2. Install Argo CD with `platform/bootstrap/install-argocd.sh`.
3. Apply namespace and guardrail manifests from `platform/bootstrap/`.
4. Register the environment applications from `platform/apps/`.

## Steady-State Changes

Use these rules for day-two operations:

- change AWS infrastructure through Terraform
- change in-cluster platform state through GitOps
- change tenant application configuration through the environment values files
- avoid direct `kubectl apply` for steady-state application delivery

## Guardrails

The bootstrap layer includes examples for:

- namespaces
- resource quotas
- limit ranges
- read-only RBAC

These are simple examples intended to show platform ownership boundaries and defaults rather than a complete production policy suite.
