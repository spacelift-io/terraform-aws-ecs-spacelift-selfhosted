variable "region" {
  type        = string
  description = "AWS region to deploy resources."
}

variable "unique_suffix" {
  type        = string
  description = "A unique suffix to append to resource names. Ideally passed from the terraform-aws-spacelift-selfhosted module's outputs."
  default     = ""
}

variable "mqtt_broker_endpoint" {
  type        = string
  description = "The endpoint of the MQTT broker in case the mqtt_broker_type is builtin. Make sure the protocol is tls:// and that you include a port number. Example: tls://spacelift-mqtt.mycorp.com:1984"

  validation {
    condition     = var.mqtt_broker_endpoint == null || can(regex("tls://.*:\\d+", var.mqtt_broker_endpoint))
    error_message = "mqtt_broker_endpoint must be in the format tls://<hostname>:<port>"
  }

  default = null
}

variable "server_domain" {
  type        = string
  description = "The domain of the server service. This should be the domain name without the protocol, for example spacelift.example.com, not https://spacelift.example.com."
  validation {
    condition     = !startswith(var.server_domain, "http://") && !startswith(var.server_domain, "https://")
    error_message = "server_domain should not include a protocol ('http://' or 'https://')"
  }
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
  description = "The subnets to deploy the MQTT load balancer in. Mandatory if mqtt_broker_type is builtin."
  default     = []
}

variable "ecs_subnets" {
  type        = list(string)
  description = "The subnets to deploy the ECS services in"
}

variable "admin_username" {
  type        = string
  description = "The admin username for the initial setup. Can be set to an empty string after the initial setup."
  sensitive   = true
  default     = ""
}

variable "admin_password" {
  type        = string
  description = "The admin password for the initial setup. Can be set to an empty string after the initial setup."
  sensitive   = true
  default     = ""
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
  description = "The connection string to the database. If not provided, the connection string URL must be passed in as part of the sensitive_env_vars variable."
  default     = null
}

variable "database_read_only_url" {
  type        = string
  description = "The read-only connection string to the database (ideally a replica). If left empty, the main database URL will be used. Optionally, this can be passed in as part of the sensitive_env_vars variable."
  default     = null
}

variable "deliveries_bucket_name" {
  type        = string
  description = "The name of the deliveries bucket."
}

variable "large_queue_messages_bucket_name" {
  type        = string
  description = "The name of the large queue messages bucket."
}

variable "metadata_bucket_name" {
  type        = string
  description = "The name of the metadata bucket."
}

variable "modules_bucket_name" {
  type        = string
  description = "The name of the modules bucket."
}

variable "policy_inputs_bucket_name" {
  type        = string
  description = "The name of the policy inputs bucket."
}

variable "run_logs_bucket_name" {
  type        = string
  description = "The name of the run logs bucket."
}

variable "states_bucket_name" {
  type        = string
  description = "The name of the states bucket."
}

variable "uploads_bucket_name" {
  type        = string
  description = "The name of the uploads bucket."
}

variable "uploads_bucket_url" {
  type        = string
  description = "The URL of the uploads bucket."
}

variable "user_uploaded_workspaces_bucket_name" {
  type        = string
  description = "The name of the user uploaded workspaces bucket."
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

variable "rsa_private_key" {
  type        = string
  description = "The base64 encoded RSA private key to use for in-app encryption. Required if encryption_type is 'rsa'."
  default     = ""
}

variable "kms_encryption_key_arn" {
  type        = string
  description = "The ARN of the KMS key to use for in-app encryption. Required if encryption_type is 'kms'."
  default     = ""
}

variable "kms_signing_key_arn" {
  type        = string
  description = "The ARN of the KMS key to use for signing JWT tokens. Required if encryption_type is 'kms'."
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

variable "drain_container_definitions" {
  type        = string
  description = "The container definitions for the drain service. If empty, a default container definition will be used."
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

variable "scheduler_container_definition" {
  type        = string
  description = "The container definition for the scheduler service. If empty, a default container definition will be used."
  default     = null
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

variable "server_container_definition" {
  type        = string
  description = "The container definition for the server service. If empty, a default container definition will be used."
  default     = null
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

variable "byo_server_target_group_arns" {
  type        = list(string)
  description = "The target groups ARNs of the BYO load balancer for server service."
  default     = []
}

variable "vcs_gateway_domain" {
  type        = string
  description = "The domain of the VCS Gateway service. This should be the domain name without the protocol, for example vcs-gateway.example.com, not https://vcs-gateway.example.com."
  default     = null
  validation {
    condition     = var.vcs_gateway_domain == null || (!startswith(var.vcs_gateway_domain, "http://") && !startswith(var.vcs_gateway_domain, "https://"))
    error_message = "vcs_gateway_domain should not include a protocol ('http://' or 'https://')"
  }
}

variable "vcs_gateway_log_configuration" {
  type        = any
  description = "The log configuration for the VCS Gateway service. See https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_LogConfiguration.html for the definition."
  default     = null
}

variable "vcs_gateway_desired_count" {
  type        = number
  description = "The desired count of the VCS gateway service. Defaults to 3 (one per availability zone)."
  default     = 3
}

variable "vcs_gateway_cpu" {
  type        = number
  description = "The CPU units to allocate to the VCS gateway service."
  default     = 1024
}

variable "vcs_gateway_container_definition" {
  type        = string
  description = "The container definition for the VCS gateway service. If empty, a default container definition will be used."
  default     = null
}

variable "vcs_gateway_memory" {
  type        = number
  description = "The memory to allocate to the VCS gateway service."
  default     = 2048
}

variable "vcs_gateway_security_group_id" {
  type        = string
  description = "The security group ID to use for the VCS gateway service."
  default     = null
}

variable "vcs_gateway_external_port" {
  type        = number
  description = "The external port for the VCS gateway load balancer used by the gRPC listener. This is used by the remote VCS Agents that connect to the VCS Gateway."
  default     = 1984
}

variable "vcs_gateway_internal_port" {
  type        = number
  description = "The port for the VCS gateway load balancer used by the internal services (server and drain)."
  default     = 1985
}

variable "vcs_gateway_internal" {
  type        = bool
  description = "Whether the VCS gateway load balancer should be internal or internet-facing. Defaults to false (internet-facing)."
  default     = false
}

variable "vcs_gateway_lb_subnets" {
  type        = list(string)
  description = "The subnets to deploy the VCS gateway load balancer in. If vcs_gateway_internal is true provide the private subnets, otherwise the public ones."
  default     = []
}

variable "vcs_gateway_certificate_arn" {
  type        = string
  description = "The ARN of the ACM certificate to use for the VCS gateway load balancer."
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

variable "ecs_service_az_rebalancing_enabled" {
  type        = bool
  description = "Enables automatic rebalancing of ECS service tasks across Availability Zones to maintain high availability and even task distribution without manual intervention. Enabled by default."
  default     = true
}

variable "sensitive_env_vars" {
  type = list(object({
    name      = string
    valueFrom = string
  }))
  description = "Sensitive environment variables to pass to the containers. It is directly passed to the 'secrets' field of the container definition. Don't forget to add the ARNs to the secrets_manager_secret_arns variable."
  default     = []
}

variable "secrets_manager_secret_arns" {
  type        = list(string)
  description = "A list of Secret Manager secret ARNs that the ECS tasks should have access to. This is used to create an execution policy that allows the ECS tasks to access the secrets."
  default     = []
}

variable "additional_env_vars" {
  type = list(object({
    name  = string
    value = string
  }))
  description = "Additional environment variables to pass to the containers."
  default     = []
}

variable "enable_automatic_usage_data_reporting" {
  type        = bool
  default     = false
  description = "Enable anonymous usage data collection."
}

variable "sqs_queues" {
  type = object({
    deadletter      = string
    deadletter_fifo = string
    async_jobs      = string
    events_inbox    = string
    async_jobs_fifo = string
    cronjobs        = string
    webhooks        = string
    iot             = string
  })
  description = "A map of SQS queue names, in case the user chooses to use SQS for message queues."
  default     = null
}

variable "iot_endpoint" {
  type        = string
  description = "The endpoint of the IoT Core service. This only needs to be specified if not using the default endpoint but a custom DNS name."
  default     = null
}

variable "mqtt_broker_type" {
  type        = string
  description = "The type of MQTT broker to use. Can be 'builtin' or 'iotcore'."
  default     = "builtin"

  validation {
    condition     = contains(["builtin", "iotcore"], var.mqtt_broker_type)
    error_message = "mqtt_broker_type must be either 'builtin' or 'iotcore'"
  }
}
