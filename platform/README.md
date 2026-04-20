# Platform Layer

This directory contains the declarative state of the EKS cluster, managed by Argo CD.

## Structure

- **bootstrap/**: Initial cluster configuration, including namespaces and basic resource quotas.
- **addons/**: (Future) Shared services like Ingress Controllers, Cert-Manager, and Monitoring.
- **apps/**: Tenant application definitions.
  - **dev/**: Development environment manifests and overrides.
  - **stage/**: Staging environment configuration.
  - **prod/**: Production environment configuration.

## GitOps Flow

1. **Bootstrap:** After the EKS cluster is created, install Argo CD using `bootstrap/install-argocd.sh`.
2. **Reconciliation:** Argo CD watches this directory. Any change to the manifests here is automatically reflected in the cluster.
3. **Application Delivery:** Applications are deployed using the `standardized-path/app` Helm chart, with environment-specific values provided in `platform/apps/{env}/values.yaml`.

## Platform Guardrails

- **Namespaces:** All workloads must run in a dedicated namespace (`dev`, `stage`, or `prod`).
- **Resource Quotas:** Namespaces have quotas defined in `bootstrap/resource-quota.yaml` to prevent resource exhaustion and ensure fair sharing of cluster resources.
- **Standardized Contract:** The Helm chart in `standardized-path/app` enforces security best practices (non-root users, resource limits).
