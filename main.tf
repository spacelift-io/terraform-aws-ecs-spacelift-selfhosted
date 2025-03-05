resource "random_uuid" "suffix" {
}

locals {
  suffix = coalesce(lower(var.unique_suffix), lower(substr(random_uuid.suffix.id, 0, 5)))

  server_port          = 1983
  mqtt_port            = 1984
  mqtt_broker_endpoint = coalesce(var.mqtt_broker_endpoint, "${var.server_domain}:${local.mqtt_port}")
}

module "lb" {
  source = "./modules/lb"

  suffix = local.suffix
  vpc_id = var.vpc_id

  server_port               = local.server_port
  server_lb_internal        = var.server_lb_internal
  server_lb_subnets         = var.server_lb_subnets
  server_lb_certificate_arn = var.server_lb_certificate_arn
  server_security_group_id  = var.server_security_group_id

  mqtt_port        = local.mqtt_port
  mqtt_lb_internal = var.mqtt_lb_internal
  mqtt_lb_subnets  = var.mqtt_lb_subnets
}

module "ecs" {
  source = "./modules/ecs"

  suffix = local.suffix

  subnets = var.subnets

  admin_username = var.admin_username
  admin_password = var.admin_password

  backend_image      = var.backend_image
  backend_image_tag  = var.backend_image_tag
  launcher_image     = var.launcher_image
  launcher_image_tag = var.launcher_image_tag

  license_token = var.license_token

  server_port                  = local.server_port
  mqtt_broker_port             = local.mqtt_port
  mqtt_broker_endpoint         = local.mqtt_broker_endpoint
  mqtt_server_target_group_arn = module.lb.mqtt_target_group_arn

  database_url           = var.database_url
  database_read_only_url = var.database_read_only_url

  deliveries_bucket_arn                = var.deliveries_bucket_arn
  deliveries_bucket_name               = var.deliveries_bucket_name
  large_queue_messages_arn             = var.large_queue_messages_arn
  large_queue_messages_bucket_name     = var.large_queue_messages_bucket_name
  metadata_bucket_arn                  = var.metadata_bucket_arn
  metadata_bucket_name                 = var.metadata_bucket_name
  modules_bucket_arn                   = var.modules_bucket_arn
  modules_bucket_name                  = var.modules_bucket_name
  policy_inputs_bucket_arn             = var.policy_inputs_bucket_arn
  policy_inputs_bucket_name            = var.policy_inputs_bucket_name
  run_logs_bucket_arn                  = var.run_logs_bucket_arn
  run_logs_bucket_name                 = var.run_logs_bucket_name
  states_bucket_arn                    = var.states_bucket_arn
  states_bucket_name                   = var.states_bucket_name
  uploads_bucket_arn                   = var.uploads_bucket_arn
  uploads_bucket_name                  = var.uploads_bucket_name
  uploads_bucket_url                   = var.uploads_bucket_url
  user_uploaded_workspaces_arn         = var.user_uploaded_workspaces_arn
  user_uploaded_workspaces_bucket_name = var.user_uploaded_workspaces_bucket_name
  workspace_bucket_arn                 = var.workspace_bucket_arn
  workspace_bucket_name                = var.workspace_bucket_name

  encryption_type                  = var.encryption_type
  encryption_kms_encryption_key_id = var.encryption_kms_encryption_key_id
  encryption_rsa_private_key       = var.encryption_rsa_private_key
  kms_key_arn                      = var.kms_key_arn

  execution_role_arn = var.execution_role_arn

  drain_cpu               = var.drain_cpu
  drain_desired_count     = var.drain_desired_count
  drain_log_configuration = var.drain_log_configuration
  drain_memory            = var.drain_memory
  drain_role_arn          = var.drain_role_arn
  drain_security_group    = var.drain_security_group_id

  scheduler_cpu               = var.scheduler_cpu
  scheduler_desired_count     = var.scheduler_desired_count
  scheduler_log_configuration = var.scheduler_log_configuration
  scheduler_memory            = var.scheduler_memory
  scheduler_role_arn          = var.scheduler_role_arn
  scheduler_security_group    = var.scheduler_security_group_id

  server_cpu               = var.server_cpu
  server_desired_count     = var.server_desired_count
  server_domain            = var.server_domain
  server_log_configuration = var.server_log_configuration
  server_memory            = var.server_memory
  server_role_arn          = var.server_role_arn
  server_security_group    = var.server_security_group_id
  server_target_group_arn  = module.lb.server_target_group_arn

  observability_vendor = var.observability_vendor
}
