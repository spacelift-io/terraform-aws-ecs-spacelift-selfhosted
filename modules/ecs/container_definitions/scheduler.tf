locals {
  scheduler_sidecar_dependencies = concat(
    var.enable_datadog_agent_sidecar && var.datadog_agent_config != null ? [{
      containerName = "datadog-agent"
      condition     = "START"
    }] : [],
    var.enable_otel_sidecar && var.otel_config != null ? [{
      containerName = "aws-otel-collector"
      condition     = "START"
    }] : []
  )

  default_scheduler_container_definition = jsonencode(concat(
    [
      merge(
        {
          name      = "scheduler"
          command   = ["spacelift", "scheduler"]
          essential = true
          image     = var.backend_image
          ulimits = [
            {
              name      = "nofile"
              softLimit = 65536
              hardLimit = 65536
            }
          ]
          logConfiguration = var.scheduler_log_configuration
          environment      = var.shared_envs
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
        length(local.scheduler_sidecar_dependencies) > 0 ? {
          dependsOn = local.scheduler_sidecar_dependencies
        } : {}
      )
    ],
    local.datadog_agent_container,
    local.otel_container
  ))
}
