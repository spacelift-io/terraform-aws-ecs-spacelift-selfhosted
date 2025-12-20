# AWS OpenTelemetry X-Ray Sidecar Configuration

This module supports injecting an AWS OpenTelemetry (OTEL) Collector sidecar container for X-Ray tracing and CloudWatch metrics into all ECS services (server, drain, scheduler, and vcs-gateway).

> [!IMPORTANT]
> **X-Ray via OpenTelemetry Collector**
>
> This example uses the **OpenTelemetry Collector** instead of the legacy X-Ray daemon. The OTEL collector sends trace data to AWS X-Ray while providing a modern, extensible architecture.
>
> **Why OpenTelemetry?** AWS X-Ray SDK/Daemon enters maintenance mode on **February 25th, 2026**, with AWS limiting future releases to security fixes only. AWS is transitioning to OpenTelemetry as the primary instrumentation standard.

## Usage

### Basic Example

```hcl
module "spacelift" {
  source = "github.com/spacelift-io/terraform-aws-ecs-spacelift-selfhosted"

  # ... other required variables ...

  # Enable OTEL X-Ray sidecar
  enable_otel_sidecar    = true
  otel_config = {
    image = "public.ecr.aws/aws-observability/aws-otel-collector:v0.46.0"
    log_configuration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = "/aws/ecs/aws-otel-collector"
        "awslogs-region"        = var.region
        "awslogs-create-group"  = "true"
        "awslogs-stream-prefix" = "otel"
      }
    }
  }
}
```

By default, the OTEL collector uses `/etc/ecs/ecs-default-config.yaml` which sends trace data directly to AWS X-Ray. You can customize this using the `config_file` variable (see [variables.tf](../../variables.tf) for all available configuration options).

> [!TIP]
> **Start with Logs Enabled**
>
> It's always recommended to start with CloudWatch logging enabled for the OpenTelemetry Collector sidecar when first setting up tracing. This allows you to verify the collector is working correctly and troubleshoot any issues. Once you've confirmed everything is working as expected, you can remove the `log_configuration` to save on CloudWatch Logs costs.

### Advanced Example with Custom Configuration

```hcl
module "ecs" {
  source = "./modules/ecs"

  # ... other required variables ...

  enable_otel_sidecar    = true

  otel_config = {
    image       = "public.ecr.aws/aws-observability/aws-otel-collector:v0.46.0"
    config_file = "/etc/ecs/ecs-amp-prometheus.yaml"  # or any config from https://github.com/aws-observability/aws-otel-collector/tree/v0.46.0/config/ecs
    additional_env_vars = [
      {
        name  = "OTEL_RESOURCE_ATTRIBUTES"
        value = "service.name=spacelift,service.version=1.0"
      }
    ]
  }
}
```

## Custom OTEL Configuration

The default configuration uses `/etc/ecs/ecs-default-config.yaml` which is built into the AWS OTEL Collector image. You can choose from several [pre-built configurations](https://github.com/aws-observability/aws-otel-collector/tree/v0.46.0/config/ecs) that are included in the image.

To use a different pre-built configuration, simply specify the config file path:

```hcl
otel_config = {
  image       = "public.ecr.aws/aws-observability/aws-otel-collector:v0.46.0"
  config_file = "/etc/ecs/ecs-xray-cloudwatch.yaml"  # For X-Ray and CloudWatch
}
```

To use a fully custom configuration, use the `config_content` parameter to provide your OTEL configuration. The configuration will be stored in AWS Secrets Manager and loaded by the collector:

```hcl
otel_config = {
  image          = "public.ecr.aws/aws-observability/aws-otel-collector:v0.46.0"
  config_content = file("${path.module}/custom-otel-config.yaml")
}
```
See [examples/with-otel-tracing](../with-otel-tracing) for a complete example using custom configuration with Grafana Cloud.

> [!IMPORTANT]
> **Updating OTEL Configuration**
>
> When using custom OTEL configuration (`config_content`), the configuration is stored in AWS Secrets Manager. To update it, simply modify the config file and apply:
>
> ```hcl
> otel_config = {
>   image          = "public.ecr.aws/aws-observability/aws-otel-collector:v0.46.0"
>   config_content = file("${path.module}/updated-otel-config.yaml")
> }
> ```
