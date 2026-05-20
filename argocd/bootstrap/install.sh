#!/usr/bin/env bash
set -euo pipefail

ARGOCD_VERSION="v2.10.4"
NAMESPACE="argocd"

echo "=== Installing Argo CD ${ARGOCD_VERSION} ==="

# Install Argo CD in the cluster
kubectl create namespace "${NAMESPACE}" --dry-run=client -o yaml | kubectl apply -f -

kubectl apply -n "${NAMESPACE}" \
  -f "https://raw.githubusercontent.com/argoproj/argo-cd/${ARGOCD_VERSION}/manifests/install.yaml"

# Wait for Argo CD to be ready
echo "=== Waiting for Argo CD components to be ready ==="
kubectl wait --for=condition=available \
  --timeout=300s \
  -n "${NAMESPACE}" \
  deployment/argocd-server \
  deployment/argocd-repo-server \
  deployment/argocd-redis \
  deployment/argocd-dex-server \
  deployment/argocd-applicationset-controller

# Apply the declarative bootstrap configuration
echo "=== Applying Argo CD declarative configuration ==="
kubectl apply -n "${NAMESPACE}" -f ../config/argocd-cm.yaml
kubectl apply -n "${NAMESPACE}" -f ../config/argocd-rbac-cm.yaml

# Apply AppProjects
echo "=== Applying AppProjects ==="
kubectl apply -f ../projects/platform.yaml
kubectl apply -f ../projects/tenant-apps.yaml

# Bootstrap the root Application (App of Apps)
echo "=== Applying root Application ==="
kubectl apply -f ../app-of-apps/root.yaml

echo "=== Argo CD bootstrap complete ==="
echo ""
echo "Access the Argo CD UI:"
echo "  kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo ""
echo "Login credentials:"
echo "  Username: admin"
echo "  Password: $(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d 2>/dev/null || echo 'retrieve with: kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d')"
