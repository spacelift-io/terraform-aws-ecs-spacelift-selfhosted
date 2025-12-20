# Datadog Agent Sidecar Configuration

This module supports injecting a Datadog agent sidecar container into all ECS services (server, drain, scheduler, and vcs-gateway).

## Usage

### Basic Example

```hcl
module "spacelift" {
  source = "github.com/spacelift-io/terraform-aws-ecs-spacelift-selfhosted"

  # ... other required variables ...

  # Enable Datadog sidecar
  enable_datadog_agent_sidecar = true
  datadog_api_key              = var.datadog_api_key  # Your Datadog API key, stored in SecretsManager (versions automatically managed)
  datadog_agent_config = {
    image = "public.ecr.aws/datadog/agent:7"
    site  = "datadoghq.com"  # or "datadoghq.eu" for EU
    tags = [
      "env:production",
      "service:spacelift",
      "team:platform"
    ]
    log_configuration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = "/aws/ecs/datadog-agent"
        "awslogs-region"        = var.region
        "awslogs-create-group"  = "true"
        "awslogs-stream-prefix" = "datadog"
      }
    }
  }
}
```

> [!IMPORTANT]
> **Rotating Datadog API Key**
>
> The Datadog API key is stored in AWS Secrets Manager. To rotate it, simply update the value and apply:
>
> ```hcl
> datadog_api_key = var.new_datadog_api_key
> ```

> [!TIP]
> **Start with Logs Enabled**
>
> It's always recommended to start with CloudWatch logging enabled for the Datadog agent sidecar when first setting up tracing. This allows you to verify the agent is working correctly and troubleshoot any issues. Once you've confirmed everything is working as expected, you can remove the `log_configuration` to save on CloudWatch Logs costs.
