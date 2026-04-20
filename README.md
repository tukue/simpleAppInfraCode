# EKS Internal Developer Platform (IDP) Reference

This repository demonstrates a modern Platform Engineering approach to managing containerized applications on Amazon EKS. It focuses on a **"Platform-as-Product"** model, providing a standardized, declarative path for application delivery.

## Platform Architecture

The platform is structured into clear layers to separate infrastructure concerns from application delivery:

```text
.
├── infra/                # Cloud Infrastructure (VPC, EKS, IAM) - Terraform/Terragrunt
├── platform/             # Platform Layer
│   ├── bootstrap/        # Initial Cluster Bootstrap (Argo CD)
│   ├── addons/           # Shared Cluster Add-ons (Ingress, Observability)
│   └── apps/             # Tenant Application Definitions (GitOps)
├── standardized-path/    # The "Golden Path"
│   └── app/              # Reusable Helm chart for all tenant workloads
└── docs/                 # Documentation and ADRs
```

## The "Golden Path" Workflow

The platform provides a standardized workflow for both Platform Engineers and Application Developers:

1.  **Infrastructure Provisioning:** Platform engineers use Terraform (managed via Terragrunt) in `infra/` to provision the AWS foundation.
2.  **Platform Bootstrap:** Argo CD is installed and points to the `platform/` directory as the source of truth for the cluster state.
3.  **Application Onboarding:** Developers use the **standardized Helm chart** in `standardized-path/app/`.
4.  **Environment Promotion:** Application state is managed via environment-specific values in `platform/apps/{dev,stage,prod}/`.

## Key Components

### 1. Infrastructure Layer (`infra/`)
- **Tooling:** Terraform & Terragrunt
- **Resources:** VPC, Subnets, EKS Cluster, Managed Node Groups, IAM Roles (IRSA).
- **State Management:** S3 Backend configured in `terragrunt.hcl`.

### 2. GitOps Layer (`platform/`)
- **Controller:** Argo CD
- **Model:** Declarative reconciliation of the entire cluster state from Git.
- **Organization:**
    - `platform/apps/dev/app.yaml`: The Argo CD Application manifest for the development environment.
    - `platform/apps/dev/values.yaml`: Environment-specific overrides (replicas, env vars).

### 3. Application Contract (`standardized-path/app/`)
- **Tooling:** Helm
- **Standardized Inputs:**
    - Container Image & Tag (Immutable versions preferred)
    - Resource Limits/Requests (Guaranteed QoS)
    - Security Context (Non-root execution)
    - Ingress Configuration
    - Environment Variables

## Getting Started

### Prerequisites
- AWS CLI & Credentials
- Terraform & Terragrunt
- kubectl & Helm

### Provision Infrastructure
```bash
cd infra
terragrunt run-all plan
terragrunt run-all apply
```

### Deploy Application (via GitOps)
1. Ensure Argo CD is installed in your cluster.
2. Apply the bootstrap manifest:
   ```bash
   kubectl apply -f platform/apps/dev/app.yaml
   ```
3. Argo CD will automatically reconcile the `app` Helm chart using the `dev` environment values.

## Design Principles
- **Declarative over Imperative:** No manual `kubectl` or `ansible` node mutations in the main flow.
- **Tenant Isolation:** Standardized charts enforce security and resource boundaries.
- **Git as Source of Truth:** Every cluster change is a Git commit.

---
*For historical or experimental assets (Ansible, raw manifests), see the `legacy/` directory.*
