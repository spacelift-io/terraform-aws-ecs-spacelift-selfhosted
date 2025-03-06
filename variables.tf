variable "region" {
  type        = string
  description = "AWS region to deploy resources."
}

variable "default_tags" {
  type        = map(string)
  description = "Default tags to apply to all resources."
  default     = {}
}

variable "unique_suffix" {
  type        = string
  description = "A unique suffix to append to resource names. Ideally passed from the terraform-aws-spacelift-selfhosted module's outputs."
  default     = ""
}

variable "mqtt_broker_endpoint" {
  type        = string
  description = "The endpoint of the MQTT broker. If empty, it'll default to server_domain:1984."
  default     = ""
}

variable "server_domain" {
  type        = string
  description = "The domain of the server service with protocol. For example: https://spacelift.mycorp.com"
}

variable "vpc_id" {
  type        = string
  description = "The VPC ID to deploy the load balancers in."
}

variable "server_lb_internal" {
  type        = bool
  description = "Whether the server load balancer should be internal or internet-facing. It's false (internet-facing) by default."
  default     = false
}

variable "server_lb_subnets" {
  type        = list(string)
  description = "The subnets to deploy the server load balancer in."
}

variable "server_lb_certificate_arn" {
  type        = string
  description = "The ARN of the ACM certificate to use for the server load balancer."
}

variable "server_security_group_id" {
  type        = string
  description = "The security group ID of the server. This is needed to allow ingress from the load balancer."
}

variable "mqtt_lb_internal" {
  type        = bool
  description = "Whether the MQTT load balancer should be internal or internet-facing. It's false (internet-facing) by default."
  default     = false
}

variable "mqtt_lb_subnets" {
  type        = list(string)
  description = "The subnets to deploy the MQTT load balancer in."
}

variable "ecs_subnets" {
  type        = list(string)
  description = "The subnets to deploy the ECS services in"
}

variable "admin_username" {
  type        = string
  description = "The admin username for the initial setup. Can be set to an empty string after the initial setup."
  sensitive   = true
  default     = null
}

variable "admin_password" {
  type        = string
  description = "The admin password for the initial setup. Can be set to an empty string after the initial setup."
  sensitive   = true
  default     = null
}

variable "backend_image" {
  type        = string
  description = "The ECR image to use for the server, scheduler and drain services."
}

variable "backend_image_tag" {
  type        = string
  description = "The tag of the backend image."
}

variable "launcher_image" {
  type        = string
  description = "The ECR image to use for the launcher service. This URL shouldn't contain the tag."
}

variable "launcher_image_tag" {
  type        = string
  description = "The tag of the launcher image."
}

variable "license_token" {
  type        = string
  description = "The license token for selfhosted, issued by Spacelift."
}

variable "database_url" {
  type        = string
  description = "The connection string to the database."
}

variable "database_read_only_url" {
  type        = string
  description = "The read-only connection string to the database (ideally a replica). If left empty, the main database URL will be used."
  default     = null
}

variable "deliveries_bucket_arn" {
  type        = string
  description = "The ARN of the deliveries bucket."
}

variable "deliveries_bucket_name" {
  type        = string
  description = "The name of the deliveries bucket."
}

variable "large_queue_messages_bucket_arn" {
  type        = string
  description = "The ARN of the large queue messages bucket."
}

variable "large_queue_messages_bucket_name" {
  type        = string
  description = "The name of the large queue messages bucket."
}

variable "metadata_bucket_arn" {
  type        = string
  description = "The ARN of the metadata bucket."
}

variable "metadata_bucket_name" {
  type        = string
  description = "The name of the metadata bucket."
}

variable "modules_bucket_arn" {
  type        = string
  description = "The ARN of the modules bucket."
}

variable "modules_bucket_name" {
  type        = string
  description = "The name of the modules bucket."
}

variable "policy_inputs_bucket_arn" {
  type        = string
  description = "The ARN of the policy inputs bucket."
}

variable "policy_inputs_bucket_name" {
  type        = string
  description = "The name of the policy inputs bucket."
}

variable "run_logs_bucket_arn" {
  type        = string
  description = "The ARN of the run logs bucket."
}

variable "run_logs_bucket_name" {
  type        = string
  description = "The name of the run logs bucket."
}

variable "states_bucket_arn" {
  type        = string
  description = "The ARN of the states bucket."
}

variable "states_bucket_name" {
  type        = string
  description = "The name of the states bucket."
}

variable "uploads_bucket_arn" {
  type        = string
  description = "The ARN of the uploads bucket."
}

variable "uploads_bucket_name" {
  type        = string
  description = "The name of the uploads bucket."
}

variable "uploads_bucket_url" {
  type        = string
  description = "The URL of the uploads bucket."
}

variable "user_uploaded_workspaces_arn" {
  type        = string
  description = "The ARN of the user uploaded workspaces bucket."
}

variable "user_uploaded_workspaces_bucket_name" {
  type        = string
  description = "The name of the user uploaded workspaces bucket."
}

variable "workspace_bucket_arn" {
  type        = string
  description = "The ARN of the workspace bucket."
}

variable "workspace_bucket_name" {
  type        = string
  description = "The name of the workspace bucket."
}

variable "encryption_type" {
  type        = string
  description = "The type of encryption to use for the buckets. Can be 'kms' or 'rsa'. This shouldn't be changed after the initial setup."
  default     = "kms"

  validation {
    condition     = var.encryption_type == "kms" || var.encryption_type == "rsa"
    error_message = "encryption_type must be either 'kms' or 'rsa'"
  }
}

variable "encryption_kms_encryption_key_id" {
  type        = string
  description = "The KMS key ID to use for in-app encryption. Required if encryption_type is 'kms'."
  default     = null
}

variable "encryption_rsa_private_key" {
  type        = string
  description = "The base64 encoded RSA private key to use for in-app encryption. Required if encryption_type is 'rsa'."
  default     = null
}

variable "kms_key_arn" {
  type        = string
  description = "The ARN of the KMS key to use for encrypting AWS resources (S3, ECR etc.)."
  default     = null
}

variable "execution_role_arn" {
  type        = string
  description = "The ARN of the ECS execution role. If empty, a new role will be created."
  default     = null
}

variable "drain_cpu" {
  type        = number
  description = "The CPU units to allocate to the drain service."
  default     = 2048
}

variable "drain_memory" {
  type        = number
  description = "The memory to allocate to the drain service."
  default     = 4096
}

variable "drain_desired_count" {
  type        = number
  description = "The desired count of the drain service. Defaults to 3 (one per availability zone)."
  default     = 3
}

variable "drain_log_configuration" {
  type        = any
  description = "The log configuration for the drain service. See https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_LogConfiguration.html for the definition."
  default     = null
}

variable "drain_role_arn" {
  type        = string
  description = "The ARN of the IAM role to use for the drain service. If empty, a new role will be created."
  default     = null
}

variable "drain_security_group_id" {
  type        = string
  description = "The security group ID to use for the drain service."
}

variable "scheduler_cpu" {
  type        = number
  description = "The CPU units to allocate to the scheduler service."
  default     = 256
}

variable "scheduler_memory" {
  type        = number
  description = "The memory to allocate to the scheduler service."
  default     = 512
}

variable "scheduler_desired_count" {
  type        = number
  description = "The desired count of the scheduler service. Defaults to 3 (one per availability zone)."
  default     = 3
}

variable "scheduler_log_configuration" {
  type        = any
  description = "The log configuration for the scheduler service. See https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_LogConfiguration.html for the definition."
  default     = null
}

variable "scheduler_role_arn" {
  type        = string
  description = "The ARN of the IAM role to use for the scheduler service. If empty, a new role will be created."
  default     = null
}

variable "scheduler_security_group_id" {
  type        = string
  description = "The security group ID to use for the scheduler service."
}

variable "server_cpu" {
  type        = number
  description = "The CPU units to allocate to the server service."
  default     = 1024
}

variable "server_memory" {
  type        = number
  description = "The memory to allocate to the server service."
  default     = 2048
}

variable "server_desired_count" {
  type        = number
  description = "The desired count of the server service. Defaults to 3 (one per availability zone)."
  default     = 3
}

variable "server_log_configuration" {
  type        = any
  description = "The log configuration for the server service. See https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_LogConfiguration.html for the definition."
  default     = null
}

variable "server_role_arn" {
  type        = string
  description = "The ARN of the IAM role to use for the server service. If empty, a new role will be created."
  default     = null
}

variable "observability_vendor" {
  type        = string
  description = "The observability vendor to use for metrics and logs."

  validation {
    condition     = contains(["AWS", "Datadog", "OpenTelemetry", "Disabled"], var.observability_vendor)
    error_message = "observability_vendor must be one of 'AWS', 'Datadog', 'OpenTelemetry', or 'Disabled'"
  }

  default = "Disabled"
}
