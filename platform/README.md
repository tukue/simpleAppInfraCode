# Platform Layer

This directory contains the declarative cluster state of the EKS cluster, managed by Argo CD.

## Structure

- **bootstrap/**: Initial cluster configuration, including namespaces, quotas, and baseline guardrails.
- **addons/**: Shared add-ons managed through GitOps, such as ingress, certificates, DNS, and metrics.
- **apps/**: Environment-specific application value overrides.
  - **dev/**: Development environment values.
  - **stage/**: Staging environment values.
  - **prod/**: Production environment values.

## GitOps Flow

1. **Bootstrap:** After the EKS cluster is created, install Argo CD using `argocd/bootstrap/install.sh`.
2. **Argo CD Configuration:** The `argocd/` directory at the repo root holds the Argo CD control plane configuration: AppProjects, the App of Apps root, ApplicationSets, RBAC, and controller settings.
3. **Reconciliation:** The root Application (`argocd/app-of-apps/root.yaml`) reconciles platform add-ons from `platform/addons/` and tenant applications from `platform/apps/`.
4. **Application Delivery:** Applications are deployed with the `standardized-path/app` Helm chart, using one values file per environment from `platform/apps/{env}/values.yaml`.
5. **Promotion:** The same chart moves through `dev`, `stage`, and `prod` by reviewed Git changes rather than direct cluster mutation.

## Platform Guardrails

- **Namespaces:** All workloads must run in a dedicated namespace (`dev`, `stage`, or `prod`).
- **Resource Quotas:** Namespaces have quotas defined in `bootstrap/resource-quota.yaml` to prevent resource exhaustion and ensure fair sharing of cluster resources.
- **Limit Ranges:** Namespaces can inherit default request and limit settings from `bootstrap/limit-range.yaml`.
- **RBAC:** Example read-only access is defined in `bootstrap/rbac-readonly.yaml`.
- **Standardized Contract:** The Helm chart in `standardized-path/app` enforces security best practices such as non-root execution, dropped capabilities, and resource limits.

## Application Manifests

Individual Application manifests in `platform/apps/<env>/simple-app.yaml` are the per-environment Argo CD Application definitions. These can be managed independently or generated through the ApplicationSet in `argocd/appsets/environments.yaml`. Both approaches target the `tenant-apps` project defined in `argocd/projects/tenant-apps.yaml`.
