# Platform Operations

## Bootstrap Sequence

1. Provision AWS infrastructure from `infra/`.
2. Install Argo CD with `platform/bootstrap/install-argocd.sh`.
3. Apply namespace and guardrail manifests from `platform/bootstrap/`.
4. Register platform add-ons from `platform/addons/`.
5. Register environment applications from `platform/apps/`.

## Steady-State Changes

Use these rules for day-two operations:

- Change AWS infrastructure through Terraform
- Change in-cluster platform state through GitOps
- Change tenant application configuration through environment values files
- Avoid direct `kubectl apply` for steady-state application delivery

## Platform Guardrails

The bootstrap layer includes:

### Namespaces
- Environment isolation (dev, stage, prod)
- Pod Security Standards enforcement (restricted profile)
- Resource quotas per namespace

### RBAC
- Read-only cluster viewer role
- Namespace-scoped developer access
- Service account token automation disabled

### Resource Controls
- CPU and memory limits per container
- Storage limits per namespace
- Pod count limits

### Network Policies
- Default deny all ingress traffic
- Allow same-namespace communication
- Explicit ingress controller access for exposed services

### Security Policies
- Non-root containers required
- Privilege escalation blocked
- Host namespaces restricted
- Read-only root filesystem encouraged

## Add-on Management

Platform add-ons are managed through Argo CD:

```bash
# Apply all add-ons
kubectl apply -f platform/addons/

# Check add-on status
kubectl get applications -n argocd
```

Available add-ons:
- nginx-ingress: Ingress controller
- cert-manager: TLS certificate automation
- metrics-server: Resource metrics for HPA
- external-dns: DNS automation (requires IRSA setup)

## Monitoring and Observability

Current approach:
- Metrics server for resource metrics
- Kubernetes events for troubleshooting
- Application logs via kubectl logs

Future enhancements:
- Prometheus for metrics collection
- Grafana for visualization
- Loki for log aggregation
- Jaeger for distributed tracing

## Secret Management

See [docs/secret-management.md](secret-management.md) for the platform secret strategy.

## Troubleshooting

### Application not syncing
```bash
kubectl get application -n argocd
kubectl describe application <app-name> -n argocd
```

### Pod not starting
```bash
kubectl get pods -n <namespace>
kubectl describe pod <pod-name> -n <namespace>
kubectl logs <pod-name> -n <namespace>
```

### Resource quota exceeded
```bash
kubectl describe resourcequota -n <namespace>
kubectl top pods -n <namespace>
```
