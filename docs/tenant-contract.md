# Tenant Contract

The supported application delivery path in this repository is the Helm chart in `standardized-path/app/`.

## What An Application Team Provides

Application teams are expected to provide values for the following inputs as needed:

- `image.repository`
- `image.tag`
- `service.port`
- `replicaCount` or `autoscaling.*`
- `ingress.*`
- `resources.requests`
- `resources.limits`
- `env`
- `serviceAccount.annotations` for workload identity integrations

## What The Platform Guarantees By Default

The chart applies baseline platform defaults so teams do not need to repeat them in every service:

- non-root execution
- dropped Linux capabilities
- read-only root filesystem
- resource requests and limits
- namespaced deployment targets
- standardized service and ingress wiring

## Supported Environment Overrides

Environment-specific configuration belongs in:

- `platform/apps/dev/values.yaml`
- `platform/apps/stage/values.yaml`
- `platform/apps/prod/values.yaml`

That separation keeps the reusable contract stable and makes promotions explicit in GitOps.
