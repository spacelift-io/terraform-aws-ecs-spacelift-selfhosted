locals {
  webhooks_endpoint = "https://${join("/", [var.server_domain, "webhooks"])}"
  backend_image     = "${var.backend_image}:${var.backend_image_tag}"
  shared_envs = [
    {
      name  = "SERVER_DOMAIN"
      value = var.server_domain
    },
    {
      name  = "MQTT_BROKER_TYPE"
      value = "builtin"
    },
    {
      name  = "MQTT_BROKER_ENDPOINT"
      value = var.mqtt_broker_endpoint
    },
    {
      name  = "ENCRYPTION_TYPE"
      value = var.encryption_type
    },
    {
      name  = "ENCRYPTION_RSA_PRIVATE_KEY"
      value = var.encryption_rsa_private_key
    },
    {
      name  = "ENCRYPTION_KMS_ENCRYPTION_KEY_ID"
      value = var.encryption_kms_encryption_key_id
    },
    {
      name  = "ENCRYPTION_KMS_SIGNING_KEY_ID"
      value = var.jwt_signing_key_arn
    },
    {
      name  = "MESSAGE_QUEUE_TYPE"
      value = "postgres"
    },
    {
      name  = "OBJECT_STORAGE_BUCKET_DELIVERIES"
      value = var.deliveries_bucket_name
    },
    {
      name  = "OBJECT_STORAGE_BUCKET_LARGE_QUEUE_MESSAGES"
      value = var.large_queue_messages_bucket_name
    },
    {
      name  = "OBJECT_STORAGE_BUCKET_MODULES"
      value = var.modules_bucket_name
    },
    {
      name  = "OBJECT_STORAGE_BUCKET_POLICY_INPUTS"
      value = var.policy_inputs_bucket_name
    },
    {
      name  = "OBJECT_STORAGE_BUCKET_RUN_LOGS"
      value = var.run_logs_bucket_name
    },
    {
      name  = "OBJECT_STORAGE_BUCKET_METADATA"
      value = var.metadata_bucket_name
    },
    {
      name  = "OBJECT_STORAGE_BUCKET_STATES"
      value = var.states_bucket_name
    },
    {
      name  = "OBJECT_STORAGE_BUCKET_USER_UPLOADED_WORKSPACES"
      value = var.user_uploaded_workspaces_bucket_name
    },
    {
      name  = "OBJECT_STORAGE_BUCKET_WORKSPACE"
      value = var.workspace_bucket_name
    },
    {
      name  = "OBJECT_STORAGE_BUCKET_USAGE_ANALYTICS"
      value = "" # Unfortunately, it's a required parameter but can be left empty
    },
    {
      name  = "OBJECT_STORAGE_BUCKET_UPLOADS"
      value = var.uploads_bucket_name
    },
    {
      name  = "OBJECT_STORAGE_BUCKET_UPLOADS_URL"
      value = var.uploads_bucket_url
    },
    {
      name  = "DATABASE_URL"
      value = var.database_url
    },
    {
      name  = "DATABASE_READ_ONLY_URL"
      value = var.database_read_only_url
    },
    {
      name  = "LICENSE_TYPE"
      value = "jwt"
    },
    {
      name  = "LICENSE_TOKEN"
      value = var.license_token
    },
    {
      name  = "OBSERVABILITY_VENDOR"
      value = var.observability_vendor
    }
  ]
}

resource "aws_ecs_task_definition" "server" {
  family = "server-${var.suffix}"

  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.server_cpu
  memory                   = var.server_memory
  execution_role_arn       = coalesce(var.execution_role_arn, aws_iam_role.execution[0].arn)
  task_role_arn            = coalesce(var.server_role_arn, aws_iam_role.server[0].arn)
  container_definitions = jsonencode([
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
}

resource "aws_ecs_task_definition" "drain" {
  family = "drain-${var.suffix}"

  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.drain_cpu
  memory                   = var.drain_memory
  execution_role_arn       = coalesce(var.execution_role_arn, aws_iam_role.execution[0].arn)
  task_role_arn            = coalesce(var.drain_role_arn, aws_iam_role.drain[0].arn)
  container_definitions = jsonencode([
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
        }
      ])
    }
  ])
}

resource "aws_ecs_task_definition" "scheduler" {
  family = "scheduler-${var.suffix}"

  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.scheduler_cpu
  memory                   = var.scheduler_memory
  execution_role_arn       = coalesce(var.execution_role_arn, aws_iam_role.execution[0].arn)
  task_role_arn            = coalesce(var.scheduler_role_arn, aws_iam_role.scheduler[0].arn)
  container_definitions = jsonencode([
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
