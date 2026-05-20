# EKS Internal Developer Platform

A platform engineering reference implementation on Amazon EKS. This repository models a small internal developer platform with clear ownership boundaries, a single paved path for application delivery, and a GitOps-driven operational model.

## Platform Model

```text
┌──────────────────────────────────────────────────────────┐
│                    Platform Team                          │
│  ┌──────────┐  ┌──────────────┐  ┌────────────────────┐  │
│  │  infra/  │  │   argocd/   │  │  platform/          │  │
│  │ Terraform│  │ AppProjects │  │  bootstrap/         │  │
│  │  VPC     │  │ App of Apps │  │  addons/            │  │
│  │  IAM     │  │ Application │  │  guardrails         │  │
│  │  EKS     │  │   Sets      │  │  network policies   │  │
│  └──────────┘  └──────────────┘  └────────────────────┘  │
│                     │                                     │
│            Argo CD reconciles                              │
│              from Git                                      │
├──────────────────────────────────────────────────────────┤
│                    App Teams                               │
│  ┌────────────────────────────────────────────────────┐   │
│  │  standardized-path/app/  (Helm contract)           │   │
│  │  platform/apps/<env>/values.yaml  (overrides)      │   │
│  │  image, port, replicas, env, secrets, ingress      │   │
│  └────────────────────────────────────────────────────┘   │
└──────────────────────────────────────────────────────────┘
```

## Who This Platform Serves

- **Platform engineers** provision and operate the cluster infrastructure, manage add-ons, and define the application delivery contract.
- **Application teams** supply lightweight configuration values and receive a standardized deployment with security defaults, resource policies, and GitOps-driven promotion.

## What Problem This Platform Solves

Without a platform, every service team independently assembles Kubernetes manifests, configures ingress, sets up RBAC, manages certificates, and defines deployment pipelines. This creates inconsistency, security gaps, and operational overhead.

This platform gives teams a **paved road** — a single supported path that covers deployment, service exposure, resource policies, security defaults, and environment promotion. Teams that stay on the paved road get these guarantees automatically. Teams can still opt out, but they assume the operational burden.

## Repository Layout

```text
.
├── argocd/               # Argo CD control plane
│   ├── projects/         # AppProject definitions (ownership boundaries)
│   ├── app-of-apps/      # Root + aggregate Application definitions
│   ├── appsets/          # ApplicationSet generators
│   ├── config/           # Controller ConfigMap + RBAC policy
│   └── bootstrap/        # Installation script
├── infra/                # Cloud infrastructure (Terraform)
│   ├── modules/          # Reusable Terraform modules
│   │   ├── vpc/
│   │   ├── iam/
│   │   └── eks/
│   ├── backend.tf        # Remote state configuration
│   └── terragrunt.hcl    # Terragrunt wrapper
├── platform/             # Declarative cluster state (Argo CD)
│   ├── bootstrap/        # Namespaces, quotas, network policies
│   ├── addons/           # Ingress, cert-manager, metrics-server, external-dns
│   └── apps/             # Environment-specific values per app
│       ├── dev/
│       ├── stage/
│       └── prod/
├── standardized-path/    # Golden path: reusable Helm chart
│   └── app/              # Tenant-facing application contract
├── docs/                 # Architecture, contract, operations
└── legacy/               # Historical assets (not in supported path)
```

## Ownership Boundaries

| Layer | Owns | Tool | Directory |
|---|---|---|---|
| **Infrastructure** | VPC, IAM roles, EKS cluster, node groups | Terraform | `infra/` |
| **Argo CD Config** | AppProjects, App of Apps, ApplicationSets, RBAC | Argo CD (declarative) | `argocd/` |
| **Cluster State** | Namespaces, quotas, add-ons, network policies | Argo CD | `platform/` |
| **App Contract** | Deployment template, service, ingress, HPA, security context | Helm | `standardized-path/app/` |
| **App Config** | Per-environment image tag, replicas, env vars | Helm values | `platform/apps/<env>/` |

## Platform Contract (Tenant API)

### What app teams provide

Inputs are defined in the Helm values schema at `standardized-path/app/values.yaml`:

- `image.repository` + `image.tag` — immutable container reference
- `service.port` — application port
- `replicaCount` or `autoscaling.*` — scaling strategy
- `ingress.*` — external exposure rules
- `resources.requests` + `resources.limits` — CPU and memory
- `env` — environment variables
- `serviceAccount.annotations` — workload identity (IRSA)

### What the platform guarantees

- Non-root execution, dropped capabilities, read-only root filesystem
- Resource limits enforced at the container and namespace level
- Consistent service and ingress wiring
- Environment isolation via dedicated namespaces with Pod Security Standards
- GitOps-driven drift detection and self-healing
- Explicit image tags (never `latest`), pinned branch revisions (never `HEAD`)

### How teams interact with the platform

1. Fork or reference the `standardized-path/app/` Helm chart.
2. Create or update environment values files under `platform/apps/<env>/`.
3. Open a pull request. CI validates the chart renders correctly.
4. Merge triggers Argo CD to reconcile the change into the cluster.
5. Promotion from dev → stage → prod follows the same Git workflow.

## GitOps Delivery Pipeline

```text
                    Git Push / PR Merge
                            │
                    ┌───────▼────────┐
                    │  Root App      │
                    │  (App of Apps) │
                    └───────┬────────┘
                            │
              ┌─────────────┼─────────────┐
              │             │             │
     ┌────────▼──────┐ ┌───▼────┐ ┌─────▼──────┐
     │ platform-     │ │ app.   │ │ per-env    │
     │ addons        │ │ sets   │ │ App. or    │
     │               │ │        │ │ AppSet     │
     └───────────────┘ └────────┘ └────────────┘
```

1. **Root Application** (`argocd/app-of-apps/root.yaml`) watches its directory and reconciles child aggregate Applications.
2. **Platform Add-ons** (`argocd/app-of-apps/platform-addons.yaml`) applies shared services from `platform/addons/` (ingress, cert-manager, metrics-server, external-dns).
3. **ApplicationSets** (`argocd/appsets/environments.yaml`) generates per-environment Application specs from a list generator, promoting consistent delivery.
4. **Standalone Applications** (`platform/apps/<env>/simple-app.yaml`) serve as alternative per-environment entry points.

## Platform Guardrails

| Guardrail | Implementation | Location |
|---|---|---|
| **Namespace isolation** | dev, stage, prod namespaces with Pod Security labels | `platform/bootstrap/namespaces.yaml` |
| **Resource quotas** | CPU, memory, pod, and service limits per namespace | `platform/bootstrap/resource-quota.yaml` |
| **Limit ranges** | Default container requests and limits per environment | `platform/bootstrap/limit-range.yaml` |
| **Network policies** | Default deny, same-ns allow, ingress-controller allow | `platform/bootstrap/network-policy.yaml` |
| **RBAC** | Read-only Role + RoleBinding for app developers | `platform/bootstrap/rbac-readonly.yaml` |
| **Security context** | Non-root, drop all caps, read-only rootfs enforced in Helm | `standardized-path/app/templates/deployment.yaml` |
| **AppProject boundaries** | Platform vs tenant-apps projects with resource whitelists | `argocd/projects/` |

## Validation Pipeline

CI validates every change against the platform contract:

| Check | Tool | Coverage |
|---|---|---|
| Terraform formatting | `terraform fmt -check` | `infra/**/*.tf` |
| Terraform validation | `terraform validate` | `infra/` |
| Terraform linting | TFLint | `infra/` (recursive, AWS plugin) |
| IaC security scan | Trivy + Terrascan | `infra/` (HIGH/CRITICAL) |
| Helm linting | `helm lint` | `standardized-path/app/` (dev, stage, prod) |
| Manifest rendering | `helm template` | All 3 environments |
| Kubernetes validation | kubeconform | Rendered manifests, Argo CD apps, bootstrap |

See `.github/workflows/` and `buildspec.yaml` for the full CI configuration.

## Environment Promotion Model

```
dev  ──►  stage  ──►  prod
 1 replica     2 replicas     3 replicas
 1.0.0-dev.1   1.0.0-rc1      1.0.0
```

The same Helm chart is promoted through environments by updating only the environment values files:

- `platform/apps/dev/values.yaml`
- `platform/apps/stage/values.yaml`
- `platform/apps/prod/values.yaml`

This keeps the application packaging stable while environment-specific policy and configuration remain visible in Git. Promotion progresses through reviewed pull requests, not direct cluster mutation.

## Day-2 Operations

| Operation | Method |
|---|---|
| Change AWS infrastructure | Terraform (`infra/`) |
| Add/modify cluster add-on | GitOps (`platform/addons/`) |
| Change app configuration | GitOps (`platform/apps/<env>/values.yaml`) |
| Rollback a deployment | Revert the Git commit |
| Add a new environment | Create values file + ApplicationSet entry |
| Add a new tenant app | Create environment values + Application manifest |
| Debug a failed sync | `kubectl describe application -n argocd` |
| Scale an application | Update `replicaCount` or HPA config in Git |

## Historical Assets

The `legacy/` directory contains earlier infrastructure experiments that are intentionally outside the supported platform path: raw Kubernetes manifests, a deprecated Helm chart, and Terraform + Ansible integration for node configuration. These are preserved for reference but are not part of the steady-state platform story.

## Further Reading

- [Platform Architecture](docs/architecture.md)
- [Tenant Contract](docs/tenant-contract.md)
- [Operations Guide](docs/operations.md)
- [GitOps / Argo CD Decision Record](docs/gitops-argocd.md)
- [Secret Management Strategy](docs/secret-management.md)
- [Improvement Plan](IMPROVEMENTS.md)
