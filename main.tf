locals {
  suffix = coalesce(lower(var.unique_suffix), lower(substr(random_uuid.suffix.id, 0, 5)))

  server_port = 1983
  mqtt_port   = var.mqtt_broker_endpoint != null ? tonumber(split(":", var.mqtt_broker_endpoint)[2]) : 0

  mqtt_broker_type     = var.mqtt_broker_type
  mqtt_broker_endpoint = var.mqtt_broker_type == "iotcore" ? coalesce(var.iot_endpoint, data.aws_iot_endpoint.iot[0].endpoint_address) : var.mqtt_broker_endpoint

  # deploy_vcs_gateway = var.vcs_gateway_certificate_arn != null && var.vcs_gateway_security_group_id != null && var.vcs_gateway_domain != null

  sqs_queues = var.sqs_queues != null ? {
    deadletter      = data.aws_sqs_queue.deadletter[0].arn
    deadletter_fifo = data.aws_sqs_queue.deadletter_fifo[0].arn
    async_jobs      = data.aws_sqs_queue.async_jobs[0].arn
    events_inbox    = data.aws_sqs_queue.events_inbox[0].arn
    async_jobs_fifo = data.aws_sqs_queue.async_jobs_fifo[0].arn
    cronjobs        = data.aws_sqs_queue.cronjobs[0].arn
    webhooks        = data.aws_sqs_queue.webhooks[0].arn
    iot             = data.aws_sqs_queue.iot[0].arn

    deadletter_url      = data.aws_sqs_queue.deadletter[0].url
    deadletter_fifo_url = data.aws_sqs_queue.deadletter_fifo[0].url
    async_jobs_url      = data.aws_sqs_queue.async_jobs[0].url
    events_inbox_url    = data.aws_sqs_queue.events_inbox[0].url
    async_jobs_fifo_url = data.aws_sqs_queue.async_jobs_fifo[0].url
    cronjobs_url        = data.aws_sqs_queue.cronjobs[0].url
    webhooks_url        = data.aws_sqs_queue.webhooks[0].url
    iot_url             = data.aws_sqs_queue.iot[0].url
  } : null

  iot_topic = var.mqtt_broker_type == "iotcore" ? "arn:${data.aws_partition.current.partition}:iot:${var.region}:${data.aws_caller_identity.current.account_id}:topic/spacelift/readonly/*" : null
}

resource "random_uuid" "suffix" {}

module "lb" {
  source = "./modules/lb"

  suffix = local.suffix
  vpc_id = var.vpc_id

  drain_security_group_id = var.drain_security_group_id

  server_port               = local.server_port
  server_lb_internal        = var.server_lb_internal
  server_lb_subnets         = var.server_lb_subnets
  server_lb_certificate_arn = var.server_lb_certificate_arn
  server_security_group_id  = var.server_security_group_id

  vcs_gateway_external_port             = var.vcs_gateway_external_port
  vcs_gateway_internal_port             = var.vcs_gateway_internal_port
  vcs_gateway_internal                  = var.vcs_gateway_internal
  vcs_gateway_lb_subnets                = var.vcs_gateway_lb_subnets
  vcs_gateway_certificate_arn           = var.vcs_gateway_certificate_arn
  vcs_gateway_service_security_group_id = var.vcs_gateway_security_group_id


  mqtt_port        = local.mqtt_port
  mqtt_lb_internal = var.mqtt_lb_internal
  mqtt_lb_subnets  = var.mqtt_lb_subnets
  mqtt_broker_type = local.mqtt_broker_type
}

module "ecs" {
  source     = "./modules/ecs"
  depends_on = [module.lb] # Prevents race conditions

  aws_account_id = data.aws_caller_identity.current.account_id
  aws_region     = var.region
  aws_partition  = data.aws_partition.current.partition

  suffix = local.suffix

  subnets = var.ecs_subnets

  admin_username = var.admin_username
  admin_password = var.admin_password

  backend_image      = var.backend_image
  backend_image_tag  = var.backend_image_tag
  launcher_image     = var.launcher_image
  launcher_image_tag = var.launcher_image_tag

  license_token = var.license_token

  server_port                  = local.server_port
  mqtt_broker_port             = local.mqtt_port
  mqtt_broker_type             = local.mqtt_broker_type
  mqtt_broker_endpoint         = local.mqtt_broker_endpoint
  mqtt_server_target_group_arn = module.lb.mqtt_target_group_arn
  byo_server_target_group_arns = var.byo_server_target_group_arns

  database_url           = var.database_url
  database_read_only_url = var.database_read_only_url

  deliveries_bucket_arn                = "arn:${data.aws_partition.current.partition}:s3:::${var.deliveries_bucket_name}"
  deliveries_bucket_name               = var.deliveries_bucket_name
  large_queue_messages_bucket_arn      = "arn:${data.aws_partition.current.partition}:s3:::${var.large_queue_messages_bucket_name}"
  large_queue_messages_bucket_name     = var.large_queue_messages_bucket_name
  metadata_bucket_arn                  = "arn:${data.aws_partition.current.partition}:s3:::${var.metadata_bucket_name}"
  metadata_bucket_name                 = var.metadata_bucket_name
  modules_bucket_arn                   = "arn:${data.aws_partition.current.partition}:s3:::${var.modules_bucket_name}"
  modules_bucket_name                  = var.modules_bucket_name
  policy_inputs_bucket_arn             = "arn:${data.aws_partition.current.partition}:s3:::${var.policy_inputs_bucket_name}"
  policy_inputs_bucket_name            = var.policy_inputs_bucket_name
  run_logs_bucket_arn                  = "arn:${data.aws_partition.current.partition}:s3:::${var.run_logs_bucket_name}"
  run_logs_bucket_name                 = var.run_logs_bucket_name
  states_bucket_arn                    = "arn:${data.aws_partition.current.partition}:s3:::${var.states_bucket_name}"
  states_bucket_name                   = var.states_bucket_name
  uploads_bucket_arn                   = "arn:${data.aws_partition.current.partition}:s3:::${var.uploads_bucket_name}"
  uploads_bucket_name                  = var.uploads_bucket_name
  uploads_bucket_url                   = var.uploads_bucket_url
  user_uploaded_workspaces_bucket_arn  = "arn:${data.aws_partition.current.partition}:s3:::${var.user_uploaded_workspaces_bucket_name}"
  user_uploaded_workspaces_bucket_name = var.user_uploaded_workspaces_bucket_name
  workspace_bucket_arn                 = "arn:${data.aws_partition.current.partition}:s3:::${var.workspace_bucket_name}"
  workspace_bucket_name                = var.workspace_bucket_name

  encryption_type        = var.encryption_type
  rsa_private_key        = var.rsa_private_key
  kms_encryption_key_arn = var.kms_encryption_key_arn
  kms_signing_key_arn    = var.kms_signing_key_arn
  kms_key_arn            = var.kms_key_arn

  execution_role_arn = var.execution_role_arn

  drain_cpu                   = var.drain_cpu
  drain_desired_count         = var.drain_desired_count
  drain_log_configuration     = var.drain_log_configuration
  drain_memory                = var.drain_memory
  drain_role_arn              = var.drain_role_arn
  drain_security_group        = var.drain_security_group_id
  drain_container_definitions = var.drain_container_definitions

  scheduler_cpu                  = var.scheduler_cpu
  scheduler_desired_count        = var.scheduler_desired_count
  scheduler_log_configuration    = var.scheduler_log_configuration
  scheduler_memory               = var.scheduler_memory
  scheduler_role_arn             = var.scheduler_role_arn
  scheduler_security_group       = var.scheduler_security_group_id
  scheduler_container_definition = var.scheduler_container_definition

  server_cpu                  = var.server_cpu
  server_desired_count        = var.server_desired_count
  server_domain               = var.server_domain
  server_log_configuration    = var.server_log_configuration
  server_memory               = var.server_memory
  server_role_arn             = var.server_role_arn
  server_security_group       = var.server_security_group_id
  server_target_group_arn     = module.lb.server_target_group_arn
  server_container_definition = var.server_container_definition

  vcs_gateway_cpu                  = var.vcs_gateway_cpu
  vcs_gateway_desired_count        = var.vcs_gateway_desired_count
  vcs_gateway_domain               = var.vcs_gateway_domain
  vcs_gateway_external_port        = var.vcs_gateway_external_port
  vcs_gateway_internal_port        = var.vcs_gateway_internal_port
  vcs_gateway_log_configuration    = var.vcs_gateway_log_configuration
  vcs_gateway_memory               = var.vcs_gateway_memory
  vcs_gateway_security_group_id    = var.vcs_gateway_security_group_id
  vcs_gateway_target_group_arn     = module.lb.vcs_gateway_target_group_arn
  vcs_gateway_container_definition = var.vcs_gateway_container_definition

  ecs_service_az_rebalancing_enabled    = var.ecs_service_az_rebalancing_enabled
  additional_env_vars                   = var.additional_env_vars
  sensitive_env_vars                    = var.sensitive_env_vars
  secrets_manager_secret_arns           = var.secrets_manager_secret_arns
  observability_vendor                  = var.observability_vendor
  enable_automatic_usage_data_reporting = var.enable_automatic_usage_data_reporting
  sqs_queues                            = local.sqs_queues
  iot_topic                             = local.iot_topic
}
