
module "spacelift" {
  source = "github.com/spacelift-io/terraform-aws-ecs-spacelift-selfhosted"

  # ... other required variables ...

  # Enable OpenTelemetry Collector with custom configuration for Grafana Cloud
  enable_otel_sidecar = true
  otel_config = {
    image = "public.ecr.aws/aws-observability/aws-otel-collector:latest"

    # Custom OTEL configuration for Grafana Cloud (config file stored in Secrets Manager safely)
    config_content = file("${path.module}/otel-config.yaml")

    # Environment variables referenced in the OTEL config (e.g., ${GRAFANA_CLOUD_OTLP_ENDPOINT})
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
