SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c
.ONESHELL:
.DELETE_ON_ERROR:
MAKEFLAGS += --no-print-directory

CLUSTER_NAME ?= platform-demo
NAMESPACE    ?= argocd
KIND_IMG     ?= kindest/node:v1.30.0

.PHONY: help
help:
	@echo 'Usage: make <target>'
	@echo ''
	@echo '  setup          Create cluster + install Argo CD + deploy platform + deploy demo app'
	@echo '  kind-up        Create Kind cluster'
	@echo '  kind-down      Delete Kind cluster'
	@echo '  argocd-install Install Argo CD and apply AppProjects'
	@echo '  deploy         Apply platform bootstrap + add-ons + demo app'
	@echo '  validate       Run CI checks locally (Helm lint + conftest)'
	@echo '  clean          kind-down + remove tmp files'
	@echo ''

.PHONY: kind-up
kind-up:
	@echo "=== Creating Kind cluster: $(CLUSTER_NAME) ==="
	kind create cluster --name $(CLUSTER_NAME) --config kind-config.yaml
	@echo "Cluster ready: $(CLUSTER_NAME)"

.PHONY: kind-down
kind-down:
	@echo "=== Deleting Kind cluster: $(CLUSTER_NAME) ==="
	kind delete cluster --name $(CLUSTER_NAME) 2>/dev/null || true

.PHONY: argocd-install
argocd-install: kind-up
	@echo "=== Installing Argo CD ==="
	cd argocd/bootstrap && ./install.sh

.PHONY: deploy
deploy:
	@echo "=== Applying platform bootstrap ==="
	kubectl apply -f platform/bootstrap/namespaces.yaml
	kubectl apply -f platform/bootstrap/resource-quota.yaml
	kubectl apply -f platform/bootstrap/limit-range.yaml
	kubectl apply -f platform/bootstrap/network-policy.yaml
	kubectl apply -f platform/bootstrap/rbac-readonly.yaml

	@echo "=== Applying platform add-ons ==="
	kubectl apply -f platform/addons/metrics-server.yaml
	kubectl apply -f platform/addons/nginx-ingress.yaml

	@echo "=== Deploying demo app (dev) ==="
	helm template simple-app-dev standardized-path/app \
	  -f platform/apps/dev/values.yaml \
	  | kubectl apply -f - 2>&1 | grep -v 'unchanged' || true

	@echo "=== Demo app status ==="
	kubectl get pods -n dev --show-labels

.PHONY: validate
validate:
	@echo "=== Helm lint ==="
	helm lint standardized-path/app -f platform/apps/dev/values.yaml
	helm lint standardized-path/app -f platform/apps/stage/values.yaml
	helm lint standardized-path/app -f platform/apps/prod/values.yaml

	@echo "=== OpenShift path renders correctly ==="
	helm template test standardized-path/app \
	  --set openshift.enabled=true \
	  --set openshift.route.enabled=true \
	  --set ingress.enabled=false \
	  | grep -q "kind: Route" && echo "  PASS: Route present"

	@echo "=== OPA policy: EKS manifests ==="
	helm template simple-app-dev standardized-path/app -f platform/apps/dev/values.yaml \
	  | tr -d '\r' | conftest test -p policy/eks/ --no-color -

	@echo "=== OPA policy: OpenShift manifests ==="
	helm template test standardized-path/app \
	  --set openshift.enabled=true \
	  --set openshift.route.enabled=true \
	  --set ingress.enabled=false \
	  | tr -d '\r' | conftest test -p policy/openshift/ --no-color -

.PHONY: setup
setup: argocd-install deploy
	@echo "=== Setup complete ==="
	@echo ""
	@echo "  Argo CD UI:  http://localhost:8080 (admin / get password below)"
	@echo "  Demo app:    kubectl get all -n dev"
	@echo ""
	@echo "  Argo CD password:"
	@kubectl -n argocd get secret argocd-initial-admin-secret \
	  -o jsonpath="{.data.password}" 2>/dev/null | base64 -d || echo "  (retrievable after install completes)"

.PHONY: clean
clean: kind-down
	@rm -f /tmp/platform-*.yaml 2>/dev/null || true
	@echo "Done."
