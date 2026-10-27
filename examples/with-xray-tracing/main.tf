module "spacelift" {
  source  = "spacelift-io/ecs-spacelift-selfhosted/aws"
  version = "~> 3.1"

  # ... other required variables ...

  # Enable OpenTelemetry Collector sidecar for X-Ray tracing
  enable_otel_sidecar = true
  otel_config = {
    image = "public.ecr.aws/aws-observability/aws-otel-collector:latest"
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
