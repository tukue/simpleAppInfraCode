# Argo CD Configuration

This directory contains the Argo CD control plane configuration for the GitOps delivery pipeline.

## Structure

```text
argocd/
├── projects/          # AppProject definitions
│   ├── platform.yaml      # Platform infrastructure project
│   └── tenant-apps.yaml   # Tenant application workloads project
├── app-of-apps/       # Root and aggregate Application definitions
│   ├── root.yaml           # Root Application (reconciles all child apps)
│   └── platform-addons.yaml # Aggregate Application for platform addons
├── appsets/           # ApplicationSet definitions
│   └── environments.yaml   # Multi-environment ApplicationSet generator
├── config/            # Argo CD controller configuration
│   ├── argocd-cm.yaml      # Argo CD ConfigMap overrides
│   └── argocd-rbac-cm.yaml # RBAC configuration
├── bootstrap/         # Bootstrap and installation scripts
│   └── install.sh          # Argo CD installation script
└── README.md
```

## GitOps Delivery Pipeline

### 1. AppProjects

Two projects define ownership boundaries:

- **platform** (`projects/platform.yaml`): Owns cluster-scoped resources, namespaces, CRDs, and platform add-ons. Platform engineers manage this project.
- **tenant-apps** (`projects/tenant-apps.yaml`): Owns namespace-scoped application workloads. Application teams deploy into dev, stage, and prod namespaces.

### 2. App of Apps Pattern

The root Application (`app-of-apps/root.yaml`) watches the `argocd/app-of-apps/` directory and reconciles all aggregate Applications within it. This means:

- `platform-addons.yaml` reconciles all add-on definitions in `platform/addons/`
- Add more aggregate Applications to this directory to extend coverage

### 3. ApplicationSet

The environment ApplicationSet (`appsets/environments.yaml`) uses a list generator to template Argo CD Application specs for dev, stage, and prod from a single definition. Each environment instance renders the same Helm chart with environment-specific values.

### 4. Promotion Flow

1. A developer updates the image tag in `platform/apps/<env>/values.yaml`
2. The change is committed to `main` via a pull request
3. Argo CD detects drift and reconciles the affected environment
4. Promotion progresses from dev -> stage -> prod through reviewed Git changes

### 5. Bootstrap Sequence

```bash
# 1. Ensure the EKS cluster is running
# 2. Install Argo CD and apply declarative config
./argocd/bootstrap/install.sh
```

## Adding a New Environment

1. Add an entry to the `list` generator in `argocd/appsets/environments.yaml`
2. Create `platform/apps/<new-env>/values.yaml` with environment-specific overrides
3. Commit and push; Argo CD will generate and sync the new Application

## RBAC Model

| Role | Scope | Permissions |
|---|---|---|
| platform-admin | All projects, clusters, repos | Full admin access |
| app-developer | tenant-apps project | Read, sync, and update applications |
| default (readonly) | Read-only across all resources | Login scope |

## References

- [Argo CD Documentation](https://argo-cd.readthedocs.io/)
- [ApplicationSet Documentation](https://argo-cd.readthedocs.io/en/stable/operator-manual/applicationset/)
- [AppProject Documentation](https://argo-cd.readthedocs.io/en/stable/user-guide/projects/)
