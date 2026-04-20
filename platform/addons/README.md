# Platform Add-ons

This directory is reserved for shared in-cluster services that are managed through GitOps rather than manually installed.

Typical add-ons for this platform layer include:

- ingress controller
- cert-manager
- external-dns
- observability stack
- policy enforcement
- external secrets integration

Add-ons should follow the same ownership model as the rest of the platform:

- Terraform provisions cloud prerequisites
- Argo CD reconciles the in-cluster add-on resources
- application teams consume the resulting platform capabilities rather than installing their own stack components
