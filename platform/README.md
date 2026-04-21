# Platform Layer

This directory contains the declarative state of the EKS cluster, managed by Argo CD.

## Structure

- **bootstrap/**: Initial cluster configuration, including Argo CD install guidance, namespaces, quotas, and baseline guardrails.
- **addons/**: Shared add-ons managed through GitOps, such as ingress, certificates, DNS, observability, and policy controllers.
- **apps/**: Tenant application definitions and environment-specific overrides.
  - **dev/**: Development environment Argo CD application and values.
  - **stage/**: Staging environment Argo CD application and values.
  - **prod/**: Production environment Argo CD application and values.

## GitOps Flow

1. **Bootstrap:** After the EKS cluster is created, install Argo CD using `bootstrap/install-argocd.sh` and apply the base bootstrap manifests.
2. **Reconciliation:** Argo CD watches the Git repository and reconciles the environment applications from `platform/apps/`.
3. **Application Delivery:** Applications are deployed with the `standardized-path/app` Helm chart, using one values file per environment from `platform/apps/{env}/values.yaml`.
4. **Promotion:** The same chart moves through `dev`, `stage`, and `prod` by reviewed Git changes rather than direct cluster mutation.

## Platform Guardrails

- **Namespaces:** All workloads must run in a dedicated namespace (`dev`, `stage`, or `prod`).
- **Resource Quotas:** Namespaces have quotas defined in `bootstrap/resource-quota.yaml` to prevent resource exhaustion and ensure fair sharing of cluster resources.
- **Limit Ranges:** Namespaces can inherit default request and limit settings from `bootstrap/limit-range.yaml`.
- **RBAC:** Example read-only access is defined in `bootstrap/rbac-readonly.yaml`.
- **Standardized Contract:** The Helm chart in `standardized-path/app` enforces security best practices such as non-root execution, dropped capabilities, and resource limits.
