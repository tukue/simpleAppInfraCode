#!/bin/bash
# Bootstrap script for Argo CD installation

set -e

ARGOCD_VERSION="v2.10.4"

echo "Creating argocd namespace..."
kubectl create namespace argocd || true

echo "Installing Argo CD ${ARGOCD_VERSION}..."
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/${ARGOCD_VERSION}/manifests/install.yaml

echo "Waiting for Argo CD to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd

echo "Argo CD ${ARGOCD_VERSION} installed successfully."
