variable "suffix" {
  type = string
}

variable "backend_image" {
  type        = string
  description = "The ECR image to use for the server, scheduler and drain services."
}

variable "backend_image_tag" {
  type        = string
  description = "The ECR image tag to use for the server, scheduler and drain services."
}

variable "admin_username" {
  type        = string
  description = "The admin username for the initial setup. Can be set to an empty string after the initial setup."
  sensitive   = true
}

variable "admin_password" {
  type        = string
  description = "The admin password for the initial setup. Can be set to an empty string after the initial setup."
  sensitive   = true
}

variable "server_desired_count" {
  type        = number
  description = "The desired count of the server service."
}

variable "drain_desired_count" {
  type        = number
  description = "The desired count of the drain service."
}

variable "scheduler_desired_count" {
  type        = number
  description = "The desired count of the scheduler service."
}

variable "drain_security_group" {
  type        = string
  description = "The security group to attach to the drain service."
}

variable "server_security_group" {
  type        = string
  description = "The security group to attach to the server service."
}

variable "scheduler_security_group" {
  type        = string
  description = "The security group to attach to the scheduler service."
}

variable "subnets" {
  type        = list(string)
  description = "The subnets to attach to the ECS services."
}

variable "drain_cpu" {
  type        = number
  description = "The CPU units to allocate to the drain service."
}

variable "server_cpu" {
  type        = number
  description = "The CPU units to allocate to the server service."
}

variable "scheduler_cpu" {
  type        = number
  description = "The CPU units to allocate to the scheduler service."
}

variable "drain_memory" {
  type        = number
  description = "The memory to allocate to the drain service."
}

variable "server_memory" {
  type        = number
  description = "The memory to allocate to the server service."
}

variable "scheduler_memory" {
  type        = number
  description = "The memory to allocate to the scheduler service."
}

variable "execution_role_arn" {
  type        = string
  description = "The ARN of the ECS execution role."
}

variable "server_role_arn" {
  type        = string
  description = "The ARN of the server ECS task role."
}

variable "drain_role_arn" {
  type        = string
  description = "The ARN of the drain ECS task role."
}

variable "scheduler_role_arn" {
  type        = string
  description = "The ARN of the scheduler ECS task role."
}

variable "server_target_group_arn" {
  type        = string
  description = "The ARN of the server target group."
}

variable "mqtt_server_target_group_arn" {
  type        = string
  description = "The ARN of the MQTT server target group."
}

variable "server_port" {
  type        = number
  description = "The port the server service listens on."
}

variable "mqtt_broker_port" {
  type        = number
  description = "The port the MQTT broker service listens on."
}

variable "server_domain" {
  type        = string
  description = "The domain of the server service."
}

variable "mqtt_broker_endpoint" {
  type        = string
  description = "The endpoint of the MQTT broker service."
}

variable "encryption_type" {
  type        = string
  description = "The type of encryption to use for the server service."

  validation {
    condition     = contains(["kms", "rsa"], var.encryption_type)
    error_message = "encryption_type must be one of 'kms' or 'rsa'"
  }
}

variable "encryption_rsa_private_key" {
  type        = string
  description = "The b64 encoded RSA private key to use for encryption. Required if encryption_type is 'rsa'."
}

variable "encryption_kms_encryption_key_id" {
  type        = string
  description = "The KMS encryption key ID to use for encryption. Required if encryption_type is 'kms'."
}

variable "jwt_signing_key_arn" {
  type        = string
  description = "The ARN of the KMS key to use for signing JWT tokens. Required if encryption_type is 'kms'."
}

variable "deliveries_bucket_name" {
  type        = string
  description = "The name of the deliveries S3 bucket."
}

variable "deliveries_bucket_arn" {
  type        = string
  description = "The ARN of the deliveries S3 bucket."
}

variable "large_queue_messages_bucket_name" {
  type        = string
  description = "The name of the large queue messages S3 bucket."
}

variable "large_queue_messages_bucket_arn" {
  type        = string
  description = "The ARN of the large queue messages S3 bucket."
}

variable "modules_bucket_name" {
  type        = string
  description = "The name of the modules S3 bucket."
}

variable "modules_bucket_arn" {
  type        = string
  description = "The ARN of the modules S3 bucket."
}

variable "policy_inputs_bucket_name" {
  type        = string
  description = "The name of the policy inputs S3 bucket."
}

variable "policy_inputs_bucket_arn" {
  type        = string
  description = "The ARN of the policy inputs S3 bucket."
}

variable "run_logs_bucket_name" {
  type        = string
  description = "The name of the run logs S3 bucket."
}

variable "run_logs_bucket_arn" {
  type        = string
  description = "The ARN of the run logs S3 bucket."
}

variable "metadata_bucket_name" {
  type        = string
  description = "The name of the metadata S3 bucket."
}

variable "metadata_bucket_arn" {
  type        = string
  description = "The ARN of the metadata S3 bucket."
}

variable "states_bucket_name" {
  type        = string
  description = "The name of the states S3 bucket."
}

variable "states_bucket_arn" {
  type        = string
  description = "The ARN of the states S3 bucket."
}

variable "user_uploaded_workspaces_bucket_name" {
  type        = string
  description = "The name of the user uploaded workspaces S3 bucket."
}

variable "user_uploaded_workspaces_bucket_arn" {
  type        = string
  description = "The ARN of the user uploaded workspaces S3 bucket."
}

variable "workspace_bucket_name" {
  type        = string
  description = "The name of the workspace S3 bucket."
}

variable "workspace_bucket_arn" {
  type        = string
  description = "The ARN of the workspace S3 bucket."
}

variable "uploads_bucket_name" {
  type        = string
  description = "The name of the uploads S3 bucket."
}

variable "uploads_bucket_arn" {
  type        = string
  description = "The ARN of the uploads S3 bucket."
}

variable "uploads_bucket_url" {
  type        = string
  description = "The URL of the uploads S3 bucket."
}

variable "database_url" {
  type        = string
  description = "The connection string for the database."
}

variable "database_read_only_url" {
  type        = string
  description = "The read only connection string for the database."
}

variable "license_token" {
  type        = string
  description = "The license token for selfhosted, issued by Spacelift."
}

variable "observability_vendor" {
  type        = string
  description = "The observability vendor to use for metrics and logs."
  validation {
    condition     = contains(["AWS", "Datadog", "OpenTelemetry", "Disabled"], var.observability_vendor)
    error_message = "observability_vendor must be one of 'AWS', 'Datadog', 'OpenTelemetry', or 'Disabled'"
  }
}

variable "server_log_configuration" {
  type        = any
  description = "The log configuration for the server service. See https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_LogConfiguration.html for the definition."
}

variable "drain_log_configuration" {
  type        = any
  description = "The log configuration for the drain service. See https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_LogConfiguration.html for the definition."
}

variable "scheduler_log_configuration" {
  type        = any
  description = "The log configuration for the scheduler service. See https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_LogConfiguration.html for the definition."
}

variable "launcher_image" {
  type        = string
  description = "The ECR image URL to use for the launcher service. Example: 123456789012.dkr.ecr.us-west-2.amazonaws.com/spacelift-launcher"
}

variable "launcher_image_tag" {
  type        = string
  description = "The ECR image tag to use for the launcher service. Example: v1.0.0"
}

variable "kms_key_arn" {
  type        = string
  description = "The ARN of the KMS key used for encrypting AWS resources (ECR, S3, etc.)."
}
