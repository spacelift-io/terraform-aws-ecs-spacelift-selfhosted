locals {
  otel_container = var.enable_otel_sidecar && var.otel_config != null ? [{
    name      = "aws-otel-collector"
    image     = var.otel_config.image
    essential = true
    command   = var.otel_config.config_content != null ? null : ["--config=${var.otel_config.config_file}"]
    environment = concat(
      [
        {
          name  = "AWS_REGION"
          value = var.aws_region
        }
      ],
      var.otel_config.additional_env_vars
    )
    secrets = var.otel_config.config_content != null ? [{
      name      = "AOT_CONFIG_CONTENT"
      valueFrom = "${var.shared_secrets_arn}:AOT_CONFIG_CONTENT::"
    }] : []
    logConfiguration = var.otel_config.log_configuration
    portMappings = [
      {
        containerPort = 2000 # X-Ray UDP port
        protocol      = "udp"
      },
      {
        containerPort = 4317 # OTLP gRPC port
        protocol      = "tcp"
      }
    ]
  }] : []
}
