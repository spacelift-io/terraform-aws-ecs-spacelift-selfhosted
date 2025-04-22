
module "this" {
  source = "../../"

  region               = var.region
  unique_suffix        = var.unique_suffix
  kms_key_arn          = var.kms_key_arn
  server_domain        = var.website_domain
  mqtt_broker_endpoint = var.mqtt_broker_endpoint

  license_token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJkaWQgeW91IHJlYWxseSB0aGluayB3ZSdsbCBhZGQgYSB2YWxpZCB0b2tlbiBoZXJlPyA6KSJ9.I60CMAP8z_ULiJgKMRrJqHgmYaiRm8PjSJh_l3AoCrU"

  encryption_type        = "kms"
  kms_encryption_key_arn = var.kms_encryption_key_arn
  kms_signing_key_arn    = var.kms_signing_key_arn

  # The secret ARNs don't need to be valid since the service desired count is 0
  sensitive_env_vars = [
    {
      name      = "DATABASE_URL",
      valueFrom = "arn:aws:secretsmanager:${var.region}:000000000000:secret:spacelift/database-abc123:DATABASE_URL::"
    },
    {
      name      = "DATABASE_READ_ONLY_URL",
      valueFrom = "arn:aws:secretsmanager:${var.region}:000000000000:secret:spacelift/database-abc123:DATABASE_READ_ONLY_URL::"
    }
  ]
  secrets_manager_secret_arns = ["arn:aws:secretsmanager:${var.region}:000000000000:secret:spacelift/database-abc123"]

  backend_image      = var.ecr_backend_repository_url
  backend_image_tag  = var.spacelift_version
  launcher_image     = var.ecr_launcher_repository_url
  launcher_image_tag = var.spacelift_version

  vpc_id      = var.vpc_id
  ecs_subnets = var.private_subnet_ids

  server_lb_subnets         = var.public_subnet_ids
  server_security_group_id  = var.server_security_group_id
  server_lb_certificate_arn = var.lb_certificate_arn
  server_desired_count      = 0

  drain_security_group_id = var.drain_security_group_id
  drain_desired_count     = 0

  scheduler_security_group_id = var.scheduler_security_group_id
  scheduler_desired_count     = 0

  mqtt_lb_subnets = var.public_subnet_ids

  # The bucket names doesn't need to be valid since the service desired count is 0
  deliveries_bucket_name               = "deliveries"
  large_queue_messages_bucket_name     = "large-queue-messages"
  metadata_bucket_name                 = "metadata"
  modules_bucket_name                  = "modules"
  policy_inputs_bucket_name            = "policy-inputs"
  run_logs_bucket_name                 = "run-logs"
  states_bucket_name                   = "states"
  uploads_bucket_name                  = "uploads"
  uploads_bucket_url                   = "uploads"
  user_uploaded_workspaces_bucket_name = "user-uploaded-workspaces"
  workspace_bucket_name                = "workspace"
}
