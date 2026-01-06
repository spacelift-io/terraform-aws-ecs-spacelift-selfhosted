locals {
  datadog_agent_container = var.enable_datadog_agent_sidecar && var.datadog_agent_config != null ? [{
    name      = "datadog-agent"
    image     = var.datadog_agent_config.image
    essential = true
    environment = concat(
      [
        {
          name  = "DD_APM_NON_LOCAL_TRAFFIC"
          value = "true"
        },
        {
          name  = "DD_DOGSTATSD_NON_LOCAL_TRAFFIC"
          value = "true"
        },
        {
          name  = "DD_SITE"
          value = var.datadog_agent_config.site
        },
        {
          name  = "DD_TAGS"
          value = join(" ", var.datadog_agent_config.tags)
        },
        {
          name  = "DD_VERSION"
          value = var.backend_image_tag
        },
        {
          name  = "ECS_FARGATE"
          value = "true"
        }
      ],
      var.datadog_agent_config.additional_env_vars
    )
    secrets = [{
      name      = "DD_API_KEY"
      valueFrom = "${var.shared_secrets_arn}:DD_API_KEY::"
    }]
    logConfiguration = var.datadog_agent_config.log_configuration
    portMappings = [
      {
        containerPort = 8125 # StatsD port
        protocol      = "udp"
      },
      {
        containerPort = 8126 # APM trace port
        protocol      = "tcp"
      }
    ]
  }] : []
}
