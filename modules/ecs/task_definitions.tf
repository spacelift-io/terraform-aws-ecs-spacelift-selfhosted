locals {
  webhooks_endpoint = "https://${var.server_domain}/webhooks"
  backend_image     = "${var.backend_image}:${var.backend_image_tag}"
  shared_envs = [
    {
      name  = "AWS_ACCOUNT_ID",
      value = var.aws_account_id
    },
    {
      name  = "AWS_DEFAULT_REGION",
      value = var.aws_region
    },
    {
      name  = "AWS_REGION",
      value = var.aws_region
    },
    {
      name  = "ENVIRONMENT",
      value = "prod"
    },
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
