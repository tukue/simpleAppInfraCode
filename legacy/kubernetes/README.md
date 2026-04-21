# Transitional Kubernetes Manifests

This directory is no longer the supported application deployment source.

Current intent:

- `argocd-application.yaml` remains as the transitional Argo CD entry point
- raw application manifests in this directory are deprecated

The single supported application deployment source for the app is:

- `../../standardized-path/app/`

Do not treat the raw application manifests in this directory as the steady-state source of truth for application delivery.
