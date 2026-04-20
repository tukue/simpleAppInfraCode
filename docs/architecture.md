# Platform Architecture

## Scope

This repository models a small internal developer platform on Amazon EKS.

- `infra/` provisions AWS resources such as VPC networking, IAM, and EKS.
- `platform/` represents the declarative cluster state reconciled by Argo CD.
- `standardized-path/app/` is the single supported application contract for tenant workloads.
- `legacy/` contains historical assets that are intentionally outside the supported path.

## Ownership Boundaries

Terraform owns:

- VPC
- IAM
- EKS cluster and node groups
- remote state configuration

Argo CD owns:

- namespaces and in-cluster guardrails
- platform add-ons
- application reconciliation for each environment

The Helm contract owns:

- deployment structure
- service exposure
- security context defaults
- environment-level application configuration

## Promotion Model

The same chart is promoted through environments by changing only the environment values files in:

- `platform/apps/dev/values.yaml`
- `platform/apps/stage/values.yaml`
- `platform/apps/prod/values.yaml`

This keeps the application packaging stable while environment-specific policy remains visible in Git.
