# Custom OpenTelemetry Configuration Example

This example demonstrates how to use a **custom OpenTelemetry Collector configuration file** with the Spacelift self-hosted deployment. Instead of using one of the default AWS OTEL configurations, you can provide your own configuration to customize receivers, processors, exporters, and pipelines.

## Overview

This example uses Grafana Cloud as the destination for traces and metrics, but the same approach can be used to send telemetry to any OTLP-compatible backend (Datadog, New Relic, Honeycomb, self-hosted Jaeger/Tempo, etc.) by modifying the `otel-config.yaml` file.

## Usage

```hcl
module "spacelift" {
  source = "github.com/spacelift-io/terraform-aws-ecs-spacelift-selfhosted"

  # ... other required variables ...

  enable_otel_sidecar = true
  otel_config = {
    image = "public.ecr.aws/aws-observability/aws-otel-collector:v0.46.0"

    config_content = file("${path.module}/otel-config.yaml")

    log_configuration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = "/aws/ecs/aws-otel-collector"
        "awslogs-region"        = var.region
        "awslogs-create-group"  = "true"
        "awslogs-stream-prefix" = "otel"
      }
    }

    additional_env_vars = [
      {
        name  = "GRAFANA_CLOUD_OTLP_ENDPOINT"
        value = var.grafana_cloud_otlp_endpoint
      },
      {
        name  = "GRAFANA_CLOUD_AUTH_HEADER"
        value = base64encode("${var.grafana_cloud_instance_id}:${var.grafana_cloud_api_token}")
      }
    ]
  }
}
```

> [!IMPORTANT]
> **Updating OTEL Configuration**
>
> The OTEL collector configuration is stored in AWS Secrets Manager. To update it, simply modify the config file and apply:
>
> ```hcl
> otel_config = {
>   image          = "public.ecr.aws/aws-observability/aws-otel-collector:v0.46.0"
>   config_content = file("${path.module}/updated-otel-config.yaml")
> }
> ```

> [!TIP]
> **Start with Logs Enabled**
>
> It's always recommended to start with CloudWatch logging enabled for the OpenTelemetry Collector sidecar when first setting up tracing. This allows you to verify the collector is working correctly and troubleshoot any issues. Once you've confirmed everything is working as expected, you can remove the `log_configuration` to save on CloudWatch Logs costs.
