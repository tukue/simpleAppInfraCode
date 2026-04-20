# Argo CD GitOps Decision

## Decision

Argo CD is the single supported GitOps controller for this repository.

This repository will not support Flux as a parallel reconciler. Running more than one GitOps controller against the same platform or application resources creates unclear ownership and unnecessary drift risk.

## Why Argo CD

Argo CD is the current choice because:

- an Argo CD `Application` manifest already exists in the repository
- the repository is being shaped around Git-driven reconciliation from a central controller
- Argo CD is a reasonable fit for bootstrapping platform resources and application deployments from Git

## Controller Ownership

Argo CD is intended to own:

- in-cluster platform resource reconciliation
- application reconciliation from Git
- drift detection and self-healing for managed resources
- environment promotion through reviewed Git changes

Terraform remains responsible for AWS infrastructure provisioning such as:

- VPC
- IAM
- EKS
- supporting infrastructure dependencies

## Current State

The current Argo CD entry points are:

- `platform/apps/dev/simple-app.yaml`
- `platform/apps/stage/simple-app.yaml`
- `platform/apps/prod/simple-app.yaml`

The current supported application source is:

- `standardized-path/app`

The repository still contains older assets that overlap with the intended GitOps model:

- raw Kubernetes manifests
- duplicate Helm chart locations
- manual `kubectl apply` usage in historical flows
- Terraform-driven Ansible execution

These assets are transitional and will be reduced over time so Argo CD can manage a clearer source of truth.

## Current Expectations

Until the repository restructure is complete, use these rules:

1. Treat Argo CD as the only intended GitOps reconciler.
2. Do not add Flux resources such as `GitRepository`, `Kustomization`, or `HelmRelease`.
3. Do not introduce a second controller for the same application resources.
4. Keep Terraform focused on infrastructure provisioning rather than in-cluster steady-state reconciliation.

## Near-Term Direction

The next GitOps improvements are:

1. Keep Argo CD pointed at the single supported Helm chart in `my-app/`.
2. Move GitOps assets into a clearer platform bootstrap structure.
3. Add environment-specific promotion structure for `dev`, `stage`, and `prod`.
4. Add validation so manifest and chart changes can be checked in CI.

## Out Of Scope

This repository is not trying to compare Argo CD and Flux side by side. The platform direction is to standardize on one controller and make ownership obvious.
