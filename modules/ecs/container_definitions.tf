locals {
  spacelift_public_api = "https://spacelift-io.app.spacelift.io"
  default_server_container_definition = jsonencode([
    {
      name      = "server"
      command   = ["spacelift", "backend", "server"]
      essential = true
      image     = local.backend_image
      portMappings = [
        {
          containerPort = var.server_port
        },
        {
          containerPort = var.mqtt_broker_port
        }
      ]
      ulimits = [
        {
          name      = "nofile"
          softLimit = 65536
          hardLimit = 65536
        }
      ]
      logConfiguration = var.server_log_configuration
      environment = concat(local.shared_envs, [
        {
          name  = "ADMIN_USERNAME"
          value = var.admin_username
        },
        {
          name  = "ADMIN_PASSWORD"
          value = var.admin_password
        },
        {
          name  = "FEATURE_FLAG_SELF_HOSTED_V3_INSTALLATION_FLOW"
          value = "true"
        },
        {
          name  = "WEBHOOKS_ENDPOINT"
          value = local.webhooks_endpoint
        }
      ])
    }
  ])

  default_drain_container_definition = jsonencode([
    {
      name      = "drain"
      command   = ["spacelift", "backend", "drain"]
      essential = true
      image     = local.backend_image
      ulimits = [
        {
          name      = "nofile"
          softLimit = 65536
          hardLimit = 65536
        }
      ]
      logConfiguration = var.drain_log_configuration
      environment = concat(local.shared_envs, [
        {
          name  = "LAUNCHER_IMAGE"
          value = var.launcher_image
        },
        {
          name  = "LAUNCHER_IMAGE_TAG"
          value = var.launcher_image_tag
        },
        {
          name  = "SPACELIFT_PUBLIC_API"
          value = var.enable_anonymous_usage_data_collection ? local.spacelift_public_api : ""
        }
      ])
    }
  ])

  default_scheduler_container_definition = jsonencode([
    {
      name      = "scheduler"
      command   = ["spacelift", "scheduler"]
      essential = true
      image     = local.backend_image
      ulimits = [
        {
          name      = "nofile"
          softLimit = 65536
          hardLimit = 65536
        }
      ]
      logConfiguration = var.scheduler_log_configuration
      environment      = local.shared_envs
    }
  ])
}
