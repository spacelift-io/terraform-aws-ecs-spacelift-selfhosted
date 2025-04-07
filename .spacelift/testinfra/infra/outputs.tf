output "unique_suffix" {
  value       = module.spacelift.unique_suffix
  description = "Randomly generated suffix for AWS resource names, ensuring uniqueness."
}

output "kms_key_arn" {
  value       = module.spacelift.kms_key_arn
  description = "ARN of the KMS key used for encrypting AWS resources."
}

output "kms_signing_key_arn" {
  value       = module.spacelift.kms_signing_key_arn
  description = "ARN of the KMS key used for signing JWTs."
}

output "kms_encryption_key_arn" {
  value       = module.spacelift.kms_encryption_key_arn
  description = "ARN of the KMS key used for in-app encryption."
}

output "server_security_group_id" {
  value       = module.spacelift.server_security_group_id
  description = "ID of the security group for the Spacelift HTTP server."
}

output "drain_security_group_id" {
  value       = module.spacelift.drain_security_group_id
  description = "ID of the security group for the Spacelift async-processing service."
}

output "database_security_group_id" {
  value       = module.spacelift.database_security_group_id
  description = "ID of the security group for the Spacelift database."
}

output "scheduler_security_group_id" {
  value       = module.spacelift.scheduler_security_group_id
  description = "ID of the scheduler security group"
}

output "database_url" {
  value       = module.spacelift.database_url
  description = "The URL to the write endpoint of the database."
  sensitive   = true
}

output "database_read_only_url" {
  value       = module.spacelift.database_read_only_url
  description = "The URL to the read endpoint of the database."
  sensitive   = true
}

output "public_subnet_ids" {
  value       = module.spacelift.public_subnet_ids
  description = "IDs of the public subnets."
}

output "private_subnet_ids" {
  value       = module.spacelift.private_subnet_ids
  description = "IDs of the private subnets."
}

output "availability_zones" {
  value       = module.spacelift.availability_zones
  description = "Availability zones of the private subnets."
}

output "vpc_id" {
  value       = module.spacelift.vpc_id
  description = "ID of the VPC."
}

output "ecr_backend_repository_url" {
  value       = module.spacelift.ecr_backend_repository_url
  description = "URL of the ECR repository for the backend images."
}

output "ecr_launcher_repository_url" {
  value       = module.spacelift.ecr_launcher_repository_url
  description = "URL of the ECR repository for the launcher images."
}

output "binaries_bucket_arn" {
  value       = module.spacelift.binaries_bucket_arn
  description = "ARN of the S3 bucket used for storing binaries."
}

output "binaries_bucket_name" {
  value       = module.spacelift.binaries_bucket_name
  description = "ID of the S3 bucket used for storing binaries."
}

output "deliveries_bucket_arn" {
  value       = module.spacelift.deliveries_bucket_arn
  description = "ARN of the S3 bucket used for storing deliveries."
}

output "deliveries_bucket_name" {
  value       = module.spacelift.deliveries_bucket_name
  description = "ID of the S3 bucket used for storing deliveries."
}

output "large_queue_messages_bucket_arn" {
  value       = module.spacelift.large_queue_messages_bucket_arn
  description = "ARN of the S3 bucket used for storing large queue messages."
}

output "large_queue_messages_bucket_name" {
  value       = module.spacelift.large_queue_messages_bucket_name
  description = "ID of the S3 bucket used for storing large queue messages."
}

output "metadata_bucket_arn" {
  value       = module.spacelift.metadata_bucket_arn
  description = "ARN of the S3 bucket used for storing metadata."
}

output "metadata_bucket_name" {
  value       = module.spacelift.metadata_bucket_name
  description = "ID of the S3 bucket used for storing metadata."
}

output "modules_bucket_arn" {
  value       = module.spacelift.modules_bucket_arn
  description = "ARN of the S3 bucket used for storing modules."
}

output "modules_bucket_name" {
  value       = module.spacelift.modules_bucket_name
  description = "ID of the S3 bucket used for storing modules."
}

output "policy_inputs_bucket_arn" {
  value       = module.spacelift.policy_inputs_bucket_arn
  description = "ARN of the S3 bucket used for storing policy inputs."
}

output "policy_inputs_bucket_name" {
  value       = module.spacelift.policy_inputs_bucket_name
  description = "ID of the S3 bucket used for storing policy inputs."
}

output "run_logs_bucket_arn" {
  value       = module.spacelift.run_logs_bucket_arn
  description = "ARN of the S3 bucket used for storing run logs."
}

output "run_logs_bucket_name" {
  value       = module.spacelift.run_logs_bucket_name
  description = "ID of the S3 bucket used for storing run logs."
}

output "states_bucket_arn" {
  value       = module.spacelift.states_bucket_arn
  description = "ARN of the S3 bucket used for storing states."
}

output "states_bucket_name" {
  value       = module.spacelift.states_bucket_name
  description = "ID of the S3 bucket used for storing states."
}

output "uploads_bucket_arn" {
  value       = module.spacelift.uploads_bucket_arn
  description = "ARN of the S3 bucket used for storing uploads."
}

output "uploads_bucket_name" {
  value       = module.spacelift.uploads_bucket_name
  description = "ID of the S3 bucket used for storing uploads."
}

output "uploads_bucket_url" {
  value       = module.spacelift.uploads_bucket_url
  description = "URL of the S3 bucket used for storing uploads."
}

output "user_uploaded_workspaces_bucket_arn" {
  value       = module.spacelift.user_uploaded_workspaces_bucket_arn
  description = "ARN of the S3 bucket used for storing user uploaded workspaces."
}

output "user_uploaded_workspaces_bucket_name" {
  value       = module.spacelift.user_uploaded_workspaces_bucket_name
  description = "ID of the S3 bucket used for storing user uploaded workspaces."
}

output "workspace_bucket_arn" {
  value       = module.spacelift.workspace_bucket_arn
  description = "ARN of the S3 bucket used for storing workspaces."
}

output "workspace_bucket_name" {
  value       = module.spacelift.workspace_bucket_name
  description = "ID of the S3 bucket used for storing workspaces."
}

output "backend_image" {
  value       = module.spacelift.ecr_backend_repository_url
  description = "The ECR URL (without the tag) of the backend image."
}

output "launcher_image" {
  value       = module.spacelift.ecr_launcher_repository_url
  description = "The ECR URL (without the tag) of the launcher image."
}
