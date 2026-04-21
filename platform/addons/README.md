# Platform Add-ons

This directory contains shared in-cluster services managed through GitOps with Argo CD.

## Available Add-ons

### nginx-ingress
Ingress controller for routing external traffic to services.

**Installation:**
```bash
kubectl apply -f platform/addons/nginx-ingress.yaml
```

### cert-manager
Automated TLS certificate management for Kubernetes.

**Installation:**
```bash
kubectl apply -f platform/addons/cert-manager.yaml
```

### metrics-server
Cluster-wide resource metrics for horizontal pod autoscaling.

**Installation:**
```bash
kubectl apply -f platform/addons/metrics-server.yaml
```

### external-dns (Placeholder)
Automatic DNS record management for services and ingresses.

**Note:** Requires IRSA configuration and environment variables.

**Setup:**
```bash
export AWS_ACCOUNT_ID="123456789012"
export AWS_REGION="eu-north-1"
./platform/addons/apply-addons.sh
```

Or apply individually:
```bash
export AWS_ACCOUNT_ID="123456789012"
export AWS_REGION="eu-north-1"
envsubst < platform/addons/external-dns.yaml | kubectl apply -f -
```

## Add-on Ownership Model

- **Terraform** provisions cloud prerequisites (IAM roles, DNS zones)
- **Argo CD** reconciles in-cluster add-on resources
- **Application teams** consume platform capabilities without installing their own infrastructure

## Applying All Add-ons

**With environment variables:**
```bash
export AWS_ACCOUNT_ID="123456789012"
export AWS_REGION="eu-north-1"
./platform/addons/apply-addons.sh
```

**Without environment variable substitution (for addons that don't need it):**
```bash
kubectl apply -f platform/addons/nginx-ingress.yaml
kubectl apply -f platform/addons/cert-manager.yaml
kubectl apply -f platform/addons/metrics-server.yaml
```

All add-ons use automated sync policies for drift detection and self-healing.
