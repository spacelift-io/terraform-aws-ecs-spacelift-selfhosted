# Spacelift Flows: its secrets, task definitions and services. Nothing here is
# created unless var.flows is set.

locals {
  flows_enabled = var.flows != null

  flows_port                  = 8080
  flows_gateway_internal_port = 6237

  # Flows reads its settings from the environment when it gets no config file.
  flows_default_environment = !local.flows_enabled ? [] : [
    {
      name  = "APP_DOMAIN"
      value = var.flows.domain
    },
    {
      name  = "LOGGING_FORMAT"
      value = "json"
    },
    {
      name  = "SERVER_PUBLIC_PORT"
      value = tostring(local.flows_port)
    },
    {
      name  = "SERVER_INTERNAL_PORT"
      value = tostring(local.flows_port)
    },
    {
      name  = "OBJECT_STORAGE_S3_BUCKET"
      value = var.flows.bucket_name
    },
    {
      name  = "OBJECT_STORAGE_S3_REGION"
      value = var.aws_region
    },
    {
      name  = "SELF_HOSTED_ORGANIZATION_NAME"
      value = var.flows.organization_name
    },
    {
      name  = "SELF_HOSTED_ADMIN_EMAIL"
      value = var.flows.admin_email
    },
    {
      name  = "DEFAULT_AGENT_POOL_ID"
      value = random_uuid.flows_default_agent_pool_id[0].result
    },
    {
      # Flows only accepts Spacelift instances it knows about.
      name  = "SPACELIFT_INSTANCES"
      value = jsonencode({ (var.server_domain) = {} })
    },
    {
      # The gateway registers the address it has in this network, and the server
      # and worker call it there. Without it, it would pick its first interface,
      # which on Fargate is not the one in the VPC.
      name  = "GATEWAY_INTERNAL_NETWORK_CIDR"
      value = var.flows.gateway_internal_network_cidr
    },
  ]

  flows_environment = !local.flows_enabled ? [] : values(merge(
    { for e in local.flows_default_environment : e.name => e },
    { for e in var.flows.additional_env_vars : e.name => e },
  ))

  flows_secrets = !local.flows_enabled ? [] : concat([
    {
      name      = "DATABASE_URL"
      valueFrom = "${aws_secretsmanager_secret.flows[0].arn}:DATABASE_URL::"
    },
    {
      name      = "SELF_HOSTED_ADMIN_PASSWORD"
      valueFrom = "${aws_secretsmanager_secret.flows[0].arn}:ADMIN_PASSWORD::"
    },
    {
      name      = "DEFAULT_AGENT_POOL_TOKEN"
      valueFrom = aws_secretsmanager_secret.flows_agent_pool_token[0].arn
    },
    {
      name      = "SELF_HOSTED_LICENSE_TOKEN"
      valueFrom = "${local.shared_secrets_arn}:LICENSE_TOKEN::"
    },
  ], var.flows.sensitive_env_vars)

  flows_payload = jsonencode({
    DATABASE_URL   = try(var.flows_secrets.database_url, "")
    ADMIN_PASSWORD = try(var.flows_secrets.admin_password, "")
  })
  flows_version_num = parseint(substr(sha256(local.flows_payload), 0, 8), 16)

  flows_secret_arns = !local.flows_enabled ? [] : [
    aws_secretsmanager_secret.flows[0].arn,
    aws_secretsmanager_secret.flows_agent_pool_token[0].arn,
  ]

  flows_components = !local.flows_enabled ? {} : {
    server = {
      cpu              = var.flows.server_cpu
      memory           = var.flows.server_memory
      desired_count    = var.flows.server_desired_count
      target_group_arn = var.flows.server_target_group_arn
    }
    worker = {
      cpu              = var.flows.worker_cpu
      memory           = var.flows.worker_memory
      desired_count    = var.flows.worker_desired_count
      target_group_arn = null
    }
    gateway = {
      cpu              = var.flows.gateway_cpu
      memory           = var.flows.gateway_memory
      desired_count    = var.flows.gateway_desired_count
      target_group_arn = var.flows.gateway_target_group_arn
    }
  }
}

resource "aws_secretsmanager_secret" "flows" {
  count = local.flows_enabled ? 1 : 0

  name                    = "spacelift/flows-secrets-${var.suffix}"
  region                  = var.aws_region
  description             = "Secrets that are used by the Spacelift Flows ECS services"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "flows" {
  count = local.flows_enabled ? 1 : 0

  region           = var.aws_region
  secret_id        = aws_secretsmanager_secret.flows[0].id
  secret_string_wo = local.flows_payload

  secret_string_wo_version = local.flows_version_num
}

# Flows seeds its default agent pool from this ID and token on first start, and
# the agents authenticate with the same pair.
resource "random_uuid" "flows_default_agent_pool_id" {
  count = local.flows_enabled ? 1 : 0
}

# Ephemeral, so the token never ends up in the state. It is written to Secrets
# Manager once: the version below never changes, so later runs don't replace it.
ephemeral "random_password" "flows_agent_pool_token" {
  count = local.flows_enabled ? 1 : 0

  length  = 64
  special = false
  upper   = false
}

resource "aws_secretsmanager_secret" "flows_agent_pool_token" {
  count = local.flows_enabled ? 1 : 0

  name                    = "spacelift/flows-agent-pool-token-${var.suffix}"
  region                  = var.aws_region
  description             = "Token of the default Spacelift Flows agent pool"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "flows_agent_pool_token" {
  count = local.flows_enabled ? 1 : 0

  region           = var.aws_region
  secret_id        = aws_secretsmanager_secret.flows_agent_pool_token[0].id
  secret_string_wo = ephemeral.random_password.flows_agent_pool_token[0].result

  secret_string_wo_version = 1
}

resource "aws_ecs_task_definition" "flows" {
  for_each = local.flows_components

  family = "flows-${each.key}-${var.suffix}"

  region                   = var.aws_region
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = each.value.cpu
  memory                   = each.value.memory
  execution_role_arn       = var.execution_role_arn != null ? var.execution_role_arn : aws_iam_role.execution[0].arn
  task_role_arn            = aws_iam_role.flows[0].arn
  container_definitions    = module.container_definitions.flows_container_definitions[each.key]
}

resource "aws_ecs_service" "flows" {
  for_each = local.flows_components

  name    = "flows-${each.key}"
  cluster = aws_ecs_cluster.cluster.id
  region  = var.aws_region

  desired_count   = each.value.desired_count
  task_definition = aws_ecs_task_definition.flows[each.key].arn

  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200
  availability_zone_rebalancing      = var.ecs_service_az_rebalancing_enabled ? "ENABLED" : "DISABLED"
  wait_for_steady_state              = true
  health_check_grace_period_seconds  = each.key == "worker" ? null : 60

  capacity_provider_strategy {
    base              = 1
    capacity_provider = "FARGATE"
    weight            = 100
  }

  network_configuration {
    assign_public_ip = false
    security_groups  = [var.flows.security_group_id]
    subnets          = var.subnets
  }

  dynamic "load_balancer" {
    for_each = each.key == "worker" ? [] : [1]
    content {
      target_group_arn = each.value.target_group_arn
      container_name   = "flows-${each.key}"
      container_port   = local.flows_port
    }
  }
}
