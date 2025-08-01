
locals {
  webhooks_endpoint = "https://${var.server_domain}/webhooks"
  backend_image     = "${var.backend_image}:${var.backend_image_tag}"

  shared_envs = concat(
    var.additional_env_vars,
    [
      {
        name  = "AWS_ACCOUNT_ID"
        value = var.aws_account_id
      },
      {
        name  = "AWS_DEFAULT_REGION"
        value = var.aws_region
      },
      {
        name  = "AWS_REGION"
        value = var.aws_region
      },
      {
        name  = "AWS_PARTITION"
        value = var.aws_partition
      },
      {
        name  = "ENVIRONMENT"
        value = "prod"
      },
      {
        name  = "SERVER_DOMAIN"
        value = var.server_domain
      },
      {
        name  = "MQTT_BROKER_TYPE"
        value = var.mqtt_broker_type
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
        value = var.rsa_private_key
      },
      {
        name  = "ENCRYPTION_KMS_ENCRYPTION_KEY_ID"
        value = var.kms_encryption_key_arn
      },
      {
        name  = "ENCRYPTION_KMS_SIGNING_KEY_ID"
        value = var.kms_signing_key_arn
      },
      {
        name  = "MESSAGE_QUEUE_TYPE"
        value = var.sqs_queues != null ? "sqs" : "postgres"
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
        value = ""
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
        name  = "LICENSE_TYPE"
        value = "jwt"
      },
      {
        name  = "OBSERVABILITY_VENDOR"
        value = var.observability_vendor
      }
    ],
    var.database_url != null ? [
      {
        name  = "DATABASE_URL"
        value = var.database_url
      }
    ] : [],
    var.database_read_only_url != null ? [
      {
        name  = "DATABASE_READ_ONLY_URL"
        value = var.database_read_only_url
      }
    ] : [],
    var.sqs_queues != null ? [
      {
        name  = "MESSAGE_QUEUE_SQS_ASYNC_URL"
        value = var.sqs_queues.async_jobs_url
      },
      {
        name  = "MESSAGE_QUEUE_SQS_ASYNC_FIFO_URL"
        value = var.sqs_queues.async_jobs_fifo_url
      },
      {
        name  = "MESSAGE_QUEUE_SQS_CRONJOBS_URL"
        value = var.sqs_queues.cronjobs_url
      },
      {
        name  = "MESSAGE_QUEUE_SQS_EVENTS_INBOX_URL"
        value = var.sqs_queues.events_inbox_url
      },
      {
        name  = "MESSAGE_QUEUE_SQS_WEBHOOKS_URL"
        value = var.sqs_queues.webhooks_url
      }
    ] : [],
    var.vcs_gateway_domain != null ? [
      {
        name  = "VCS_GATEWAY_ENDPOINT"
        value = "${var.vcs_gateway_domain}:443"
      }
    ] : []
  )
}

resource "aws_ecs_task_definition" "server" {
  family = "server-${var.suffix}"

  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.server_cpu
  memory                   = var.server_memory
  execution_role_arn       = var.execution_role_arn != null ? var.execution_role_arn : aws_iam_role.execution[0].arn
  task_role_arn            = var.server_role_arn != null ? var.server_role_arn : aws_iam_role.server[0].arn
  container_definitions    = coalesce(var.server_container_definition, local.default_server_container_definition)
}

resource "aws_ecs_task_definition" "drain" {
  family = "drain-${var.suffix}"

  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.drain_cpu
  memory                   = var.drain_memory
  execution_role_arn       = var.execution_role_arn != null ? var.execution_role_arn : aws_iam_role.execution[0].arn
  task_role_arn            = var.drain_role_arn != null ? var.drain_role_arn : aws_iam_role.drain[0].arn
  container_definitions    = coalesce(var.drain_container_definitions, local.default_drain_container_definition)
}

resource "aws_ecs_task_definition" "scheduler" {
  family = "scheduler-${var.suffix}"

  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.scheduler_cpu
  memory                   = var.scheduler_memory
  execution_role_arn       = var.execution_role_arn != null ? var.execution_role_arn : aws_iam_role.execution[0].arn
  task_role_arn            = var.scheduler_role_arn != null ? var.scheduler_role_arn : aws_iam_role.scheduler[0].arn
  container_definitions    = coalesce(var.scheduler_container_definition, local.default_scheduler_container_definition)
}

resource "aws_ecs_task_definition" "vcs_gateway" {
  count = var.vcs_gateway_security_group_id != null ? 1 : 0

  family = "vcs-gateway-${var.suffix}"

  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.vcs_gateway_cpu
  memory                   = var.vcs_gateway_memory
  execution_role_arn       = var.execution_role_arn != null ? var.execution_role_arn : aws_iam_role.execution[0].arn
  task_role_arn            = aws_iam_role.vcs_gateway[0].arn
  container_definitions    = coalesce(var.vcs_gateway_container_definition, local.default_vcs_gateway_container_definition)
}
