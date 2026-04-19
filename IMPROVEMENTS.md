# Repo Improvement Plan

## Goal

Improve this repository so it demonstrates stronger platform engineering judgment, clearer architecture, and a more credible platform-as-product story.

## Current Gaps

The repository currently mixes several concerns in a way that weakens the overall platform narrative:

- Infrastructure provisioning, node configuration, GitOps, raw Kubernetes manifests, and Helm packaging are all combined in one flow.
- There are multiple deployment paths instead of one supported golden path.
- GitOps is partially introduced through Argo CD, but the repository does not yet have a single declarative source of truth.
- The repository does not clearly show a tenant-facing platform contract for application teams.
- Duplicate and inconsistent assets make the repo harder to understand quickly.

## What A Stronger Platform Repo Should Show

A stronger platform engineering portfolio project should make the following clear:

- What problem the platform solves
- Who the users are
- What the supported developer workflow is
- What is provisioned by infrastructure code
- What is reconciled by GitOps
- What application teams are expected to provide
- What the platform guarantees by default

## Recommended Direction

Standardize the repository around this model:

- Terraform for cloud infrastructure provisioning
- Argo CD for in-cluster GitOps reconciliation
- One Helm chart as the application deployment contract
- Environment-specific configuration for promotion between `dev`, `stage`, and `prod`

This keeps the architecture easy to explain and aligns well with common platform engineering practices.

## Priority Improvements

### 1. Define One Clear Platform Story

Update the repository README so the project is described as a small internal developer platform on EKS rather than a collection of infrastructure experiments.

The README should explain:

- the platform goal
- the target users
- the golden path for deploying an app
- the role of Terraform, Argo CD, and Helm

### 2. Restructure the Repository

Move the code into clearer platform layers. A better target structure is:

```text
infra/
platform/bootstrap/
platform/addons/
platform/apps/
golden-path/
docs/
```

Suggested ownership:

- `infra/`: VPC, IAM, EKS, backend, Terragrunt
- `platform/bootstrap/`: Argo CD installation and initial cluster bootstrap
- `platform/addons/`: ingress, cert-manager, external-dns, observability, policies
- `platform/apps/`: application definitions reconciled by Argo CD
- `golden-path/`: reusable Helm chart or application template
- `docs/`: architecture, onboarding, operations, tradeoffs

### 3. Remove Competing Deployment Paths

Choose one supported application delivery path.

Recommended:

- Argo CD reconciles the application from Git
- The application is packaged with a single Helm chart

Then reduce or remove:

- duplicate Helm chart directories
- raw manifests that bypass the chart
- manual `kubectl apply` paths for steady-state deployment
- manual `helm install` instructions as the primary workflow

### 4. Make GitOps Real

Strengthen the GitOps model by:

- replacing `HEAD` with explicit revisions or environment branches
- replacing `latest` image tags with immutable versions
- making the Argo CD application point to the actual source of truth
- organizing environment-specific values or overlays
- documenting promotion flow between environments

### 5. Remove Imperative Node Mutation From The Main Story

The current Terraform and Ansible integration makes the platform look more imperative than declarative.

For a stronger platform engineering profile, reduce reliance on:

- `local-exec`
- SSH-based node configuration
- post-provisioning drift outside GitOps

Prefer:

- EKS managed features
- launch templates when required
- IRSA for workload permissions
- GitOps-managed cluster add-ons

### 6. Define A Tenant-Facing Contract

Add a simple, reusable application contract that shows what a developer provides to the platform.

For example:

- container image
- port
- replicas
- ingress or exposure type
- CPU and memory
- environment variables
- secret references

This contract should be represented by one reusable Helm chart or application template.

### 7. Add Platform Guardrails

A platform repo should show more than deployment mechanics.

Add examples or documentation for:

- namespace strategy
- RBAC model
- resource quotas
- limit ranges
- ingress standardization
- workload identity
- secret management strategy
- observability defaults

### 8. Improve Validation And CI

Add CI checks that validate the platform code:

- `terraform fmt`
- `terraform validate`
- `tflint`
- `helm lint`
- manifest validation
- security or policy scans where relevant

This helps the repository look production-minded rather than purely demonstrative.

### 9. Clean Up Naming And Duplication

Repository hygiene matters.

Recommended cleanup:

- rename `kubernets/` to `kubernetes/`
- keep only one Helm chart location
- move experiments or backups into `examples/` or `archive/`
- remove obsolete files from the main path

## Suggested Improvements

1. Clarify the repository narrative in `README.md`
2. Choose Argo CD as the single GitOps controller
3. Keep one Helm chart as the application golden path
4. Reorganize the repository into infrastructure and platform layers
5. Remove Ansible from the main steady-state platform flow
6. Add environment-specific application promotion structure
7. Add platform guardrails and operational documentation
8. Add CI validation for Terraform, Helm, and manifests

## Expected Outcome

After these changes, the repository should read less like a mixed infrastructure lab and more like a focused platform engineering project that demonstrates:

- architectural clarity
- GitOps discipline
- reusable platform abstractions
- operational thinking
- developer experience awareness

## Next Step

The next practical change should be a `README.md` rewrite and a repository restructure plan so the code layout matches the intended platform story.
