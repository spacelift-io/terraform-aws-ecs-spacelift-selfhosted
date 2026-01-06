locals {
  server_sidecar_dependencies = concat(
    var.enable_datadog_agent_sidecar && var.datadog_agent_config != null ? [{
      containerName = "datadog-agent"
      condition     = "START"
    }] : [],
    var.enable_otel_sidecar && var.otel_config != null ? [{
      containerName = "aws-otel-collector"
      condition     = "START"
    }] : []
  )

  default_server_container_definition = jsonencode(concat(
    [
      merge(
        {
          name      = "server"
          command   = ["spacelift", "backend", "server"]
          essential = true
          image     = var.backend_image
          portMappings = concat(
            [
              {
                containerPort = var.server_port
              }
            ],
            var.mqtt_broker_port != 0 ? [
              {
                containerPort = var.mqtt_broker_port
              }
            ] : []
          )
          ulimits = [
            {
              name      = "nofile"
              softLimit = 65536
              hardLimit = 65536
            }
          ]
          logConfiguration = var.server_log_configuration
          environment = concat(var.shared_envs, [
            {
              name  = "ADMIN_USERNAME"
              value = var.admin_username
            },
            {
              name  = "ADMIN_PASSWORD"
              value = var.admin_password
            },
            {
              name  = "AWS_S3_US_EAST_1_REGIONAL_ENDPOINT"
              value = "regional"
            },
            {
              name  = "WEBHOOKS_ENDPOINT"
              value = var.webhooks_endpoint
            }
          ])
          secrets = concat(
            [
              {
                name      = "LICENSE_TOKEN",
                valueFrom = "${var.shared_secrets_arn}:LICENSE_TOKEN::"
              }
            ],
            var.sensitive_env_vars
          )
        },
        length(local.server_sidecar_dependencies) > 0 ? {
          dependsOn = local.server_sidecar_dependencies
        } : {}
      )
    ],
    local.datadog_agent_container,
    local.otel_container
  ))
}
