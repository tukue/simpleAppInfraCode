# EKS Internal Developer Platform Reference

This repository presents a small internal developer platform on Amazon EKS. The intended users are platform engineers who provision and bootstrap the cluster, and application teams who deploy workloads through a single supported delivery contract.

The repo is organized around one platform story:

- Terraform provisions AWS infrastructure in `infra/`
- Argo CD reconciles in-cluster state from Git in `platform/`
- One reusable Helm chart in `standardized-path/app/` defines the tenant-facing application contract
- Environment promotion is expressed through `platform/apps/dev`, `platform/apps/stage`, and `platform/apps/prod`

## What Problem The Platform Solves

Application teams should not need to assemble raw Kubernetes manifests, bespoke ingress configuration, and ad hoc runtime defaults for every service. This platform gives them a standardized path that covers deployment, service exposure, resource policies, and baseline security settings.

## Repository Layout

```text
.
├── infra/                # Terraform and Terragrunt for VPC, IAM, and EKS
├── platform/
│   ├── bootstrap/        # Argo CD install and foundational cluster guardrails
│   ├── addons/           # Shared add-ons managed through GitOps
│   └── apps/             # Environment-specific Argo CD applications and values
├── standardized-path/
│   └── app/              # Reusable Helm chart used by tenant applications
├── docs/                 # Architecture, platform contract, and operations
└── legacy/               # Historical assets kept out of the supported path
```

## Supported Workflow

1. Platform engineers provision AWS infrastructure from `infra/`.
2. Platform engineers bootstrap Argo CD and base namespaces from `platform/bootstrap/`.
3. Application teams supply the inputs required by the Helm contract in `standardized-path/app/`.
4. Argo CD reconciles the application manifests for `dev`, `stage`, and `prod` from `platform/apps/`.
5. Promotion happens by updating reviewed Git changes, not by manual cluster mutation.

## Platform Contract

The supported tenant-facing inputs are documented in [docs/tenant-contract.md](/mnt/c/Users/tukue/simpleAppInfraCode/docs/tenant-contract.md:1). In practice, a team provides:

- immutable container image reference
- service port
- replica count or autoscaling settings
- ingress exposure rules
- resource requests and limits
- environment variables
- secret references or service account annotations when needed

The platform chart applies defaults for:

- non-root containers
- dropped Linux capabilities
- read-only root filesystem
- resource-aware deployments
- namespaced delivery per environment

## GitOps Model

Argo CD is the single supported GitOps controller. Each environment has one `Application` manifest under `platform/apps/<env>/simple-app.yaml`, and each one renders the same Helm chart with environment-specific overrides from `platform/apps/<env>/values.yaml`.

The Argo CD applications are pinned to the `main` branch rather than `HEAD`, and the chart values use explicit image tags instead of `latest`.

## Validation

The repo validates the supported platform path through:

- Terraform formatting and validation
- Helm linting
- Helm template rendering for `dev`, `stage`, and `prod`

See `.github/workflows/` and `buildspec.yaml` for the validation entry points.

## Historical Assets

Older experiments remain in `legacy/` for reference, but they are not part of the steady-state platform story. That includes raw Kubernetes manifests, duplicate Helm assets, and Terraform plus Ansible flows that bypass GitOps.
