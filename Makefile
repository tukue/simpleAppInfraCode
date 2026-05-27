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
	@echo '  test           Run Helm unit tests'
	@echo '  validate       Run CI checks locally (Helm lint + test + conftest)'
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
	kubectl apply -f platform/bootstrap/cluster-secret-store.yaml

	@echo "=== Creating platform secrets namespace ==="
	kubectl create namespace platform-secrets --dry-run=client -o yaml | kubectl apply -f -

	@echo "=== Seeding dev secret for demo ==="
	kubectl create secret generic dev-simple-app-db-password \
	  --from-literal=db-password=local-dev-password \
	  -n platform-secrets --dry-run=client -o yaml | kubectl apply -f -

	@echo "=== Applying platform add-ons ==="
	kubectl apply -f platform/addons/metrics-server.yaml
	kubectl apply -f platform/addons/nginx-ingress.yaml
	kubectl apply -f platform/addons/external-secrets.yaml
	kubectl apply -f platform/addons/kube-prometheus-stack.yaml
	kubectl apply -f platform/addons/grafana-dashboards-platform.yaml

	@echo "=== Deploying simple-app ==="
	helm template simple-app-dev standardized-path/app \
	  -f platform/apps/dev/values.yaml \
	  | kubectl apply -f - 2>&1 | grep -v 'unchanged' || true

	@echo "=== Deploying app-b ==="
	helm template app-b-dev standardized-path/app \
	  -f platform/apps/app-b/dev/values.yaml \
	  | kubectl apply -f - 2>&1 | grep -v 'unchanged' || true

	@echo "=== App status ==="
	kubectl get pods -n dev --show-labels

.PHONY: test
test:
	@echo "=== Helm unit tests ==="
	helm unittest standardized-path/app --color

.PHONY: validate
validate: test
	@echo "=== Helm lint ==="
	helm lint standardized-path/app -f platform/apps/dev/values.yaml
	helm lint standardized-path/app -f platform/apps/stage/values.yaml
	helm lint standardized-path/app -f platform/apps/prod/values.yaml

	@echo "=== ServiceMonitor renders ==="
	helm template simple-app-dev standardized-path/app -f platform/apps/dev/values.yaml \
	  | grep -q "kind: ServiceMonitor" && echo "  PASS: ServiceMonitor present"

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
