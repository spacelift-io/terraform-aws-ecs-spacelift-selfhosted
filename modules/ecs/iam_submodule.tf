module "iam_roles_and_policies" {
  source = "github.com/spacelift-io/terraform-aws-iam-spacelift-selfhosted?ref=v1.2.1"

  write_as_files = false
  aws_partition  = var.aws_partition

  secrets_manager_secret_arns = var.secrets_manager_secret_arns

  kms_encryption_key_arn = var.kms_encryption_key_arn
  kms_signing_key_arn    = var.kms_signing_key_arn
  kms_key_arn            = var.kms_key_arn

  deliveries_bucket_name               = var.deliveries_bucket_name
  large_queue_messages_bucket_name     = var.large_queue_messages_bucket_name
  metadata_bucket_name                 = var.metadata_bucket_name
  modules_bucket_name                  = var.modules_bucket_name
  policy_inputs_bucket_name            = var.policy_inputs_bucket_name
  run_logs_bucket_name                 = var.run_logs_bucket_name
  states_bucket_name                   = var.states_bucket_name
  uploads_bucket_name                  = var.uploads_bucket_name
  user_uploaded_workspaces_bucket_name = var.user_uploaded_workspaces_bucket_name
  workspace_bucket_name                = var.workspace_bucket_name

  sqs_queues = var.sqs_queues
  iot_topic  = var.iot_topic
}
