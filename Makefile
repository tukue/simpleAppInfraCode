SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c
.ONESHELL:
.DELETE_ON_ERROR:
MAKEFLAGS += --no-print-directory

CLUSTER_NAME ?= platform-demo
NAMESPACE    ?= argocd
KIND_IMG     ?= kindest/node:v1.30.0
AWS_ACCOUNT_ID ?= 944684220857
AWS_REGION     ?= eu-north-1
IMAGE_REPO     ?= $(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com/app

.PHONY: help
help:
	@echo 'Usage: make <target>'
	@echo ''
	@echo '  setup          Create cluster + install Argo CD + deploy platform + deploy demo app'
	@echo '  kind-up        Create Kind cluster'
	@echo '  kind-down      Delete Kind cluster'
	@echo '  argocd-install Install Argo CD and apply AppProjects'
	@echo '  deploy         Apply platform bootstrap (Argo CD reconciles add-ons and apps via GitOps)'
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
	@echo "=== Applying platform bootstrap (foundation for Argo CD) ==="
	kubectl apply -f platform/bootstrap/

	@echo "=== Creating platform secrets namespace ==="
	kubectl create namespace platform-secrets --dry-run=client -o yaml | kubectl apply -f -

	@echo "=== Seeding dev secret for demo ==="
	kubectl create secret generic dev-simple-app-db-password \
	  --from-literal=db-password=$${DEV_DB_PASSWORD:-changeme} \
	  -n platform-secrets --dry-run=client -o yaml | kubectl apply -f -

	@echo "=== Argo CD manages add-ons and apps via GitOps (app-of-apps) ==="
	@echo "  Root app:      kubectl get application/root -n argocd"
	@echo "  Child apps:    kubectl get applications -n argocd"
	@echo ""

	@echo "=== Waiting for Argo CD to reconcile add-ons ==="
	@for i in 1 2 3 4 5; do \
	  ready=$$(kubectl -n argocd get applications 2>/dev/null | tail -n+2 | wc -l); \
	  [ "$$ready" -gt 0 ] && break; \
	  sleep 3; \
	done
	kubectl get applications -n argocd 2>/dev/null || echo "(Argo CD syncing add-ons and apps)"

	@echo ""
	@echo "=== Pod status ==="
	@for ns in dev stage prod; do \
	  echo "--- $$ns ---"; \
	  kubectl get pods -n $$ns --show-labels 2>/dev/null || echo "(no pods yet - Argo CD is syncing)"; \
	done

.PHONY: test
test:
	@echo "=== Helm unit tests ==="
	helm unittest standardized-path/app --color

.PHONY: validate
validate: test
	@echo "=== Immutable tags and revisions ==="
	@for f in platform/apps/**/values.yaml; do \
	  [ -f "$$f" ] || continue; \
	  tag_val=$$(grep -E '^\s+tag:' "$$f" | sed 's/.*tag:\s*"\{0,1\}\([^"]*\)"\{0,1\}/\1/' | xargs); \
	  if [ "$$tag_val" = "latest" ]; then \
	    echo "  FAIL: $$f uses 'latest' tag"; exit 1; \
	  fi; \
	done
	@for f in argocd/**/*.yaml; do \
	  [ -f "$$f" ] || continue; \
	  if grep -qE 'targetRevision:\s*"?HEAD"?' "$$f" 2>/dev/null; then \
	    echo "  FAIL: $$f uses 'HEAD' revision"; exit 1; \
	  fi; \
	done
	@echo "  PASS"

	@echo "=== Helm lint ==="
	helm lint standardized-path/app -f platform/apps/dev/values.yaml
	helm lint standardized-path/app -f platform/apps/stage/values.yaml
	helm lint standardized-path/app -f platform/apps/prod/values.yaml

	@echo "=== ServiceMonitor renders ==="
	helm template simple-app-dev standardized-path/app -f platform/apps/dev/values.yaml \
	  --set image.repository=$(IMAGE_REPO) \
	  | grep -q "kind: ServiceMonitor" && echo "  PASS: ServiceMonitor present"

	@echo "=== OpenShift path renders correctly ==="
	helm template test standardized-path/app \
	  --set image.repository=$(IMAGE_REPO) \
	  --set openshift.enabled=true \
	  --set openshift.route.enabled=true \
	  --set ingress.enabled=false \
	  | grep -q "kind: Route" && echo "  PASS: Route present"

	@echo "=== OPA policy: EKS manifests ==="
	helm template simple-app-dev standardized-path/app -f platform/apps/dev/values.yaml \
	  --set image.repository=$(IMAGE_REPO) \
	  | tr -d '\r' | conftest test -p policy/eks/ --no-color -

	@echo "=== OPA policy: OpenShift manifests ==="
	helm template test standardized-path/app \
	  --set image.repository=$(IMAGE_REPO) \
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
