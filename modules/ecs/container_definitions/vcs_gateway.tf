locals {
  vcs_gateway_sidecar_dependencies = concat(
    var.enable_datadog_agent_sidecar && var.datadog_agent_config != null ? [{
      containerName = "datadog-agent"
      condition     = "START"
    }] : [],
    var.enable_otel_sidecar && var.otel_config != null ? [{
      containerName = "aws-otel-collector"
      condition     = "START"
    }] : []
  )

  default_vcs_gateway_container_definition = jsonencode(concat(
    [
      merge(
        {
          name      = "vcs-gateway"
          command   = ["spacelift", "backend", "vcs-gateway"]
          essential = true
          image     = var.backend_image
          portMappings = [
            {
              containerPort = var.vcs_gateway_external_port
            },
            {
              containerPort = var.vcs_gateway_internal_port
            }
          ]
          ulimits = [
            {
              name      = "nofile"
              softLimit = 65536
              hardLimit = 65536
            }
          ]
          logConfiguration = var.vcs_gateway_log_configuration
          environment = concat(var.shared_envs, [
            {
              name  = "GATEWAY_GRPC_PORT"
              value = tostring(var.vcs_gateway_external_port)
            },
            {
              name  = "GATEWAY_HTTP_PORT"
              value = tostring(var.vcs_gateway_internal_port)
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
        length(local.vcs_gateway_sidecar_dependencies) > 0 ? {
          dependsOn = local.vcs_gateway_sidecar_dependencies
        } : {}
      )
    ],
    local.datadog_agent_container,
    local.otel_container
  ))
}
