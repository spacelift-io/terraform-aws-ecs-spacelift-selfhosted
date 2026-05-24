# Backend configuration
variable "backend_image" {
  type        = string
  description = "The backend container image with tag"
}

variable "backend_image_tag" {
  type        = string
  description = "The backend image tag (for DD_VERSION)"
}

# Shared environment variables
variable "shared_envs" {
  type = list(object({
    name  = string
    value = string
  }))
  description = "Shared environment variables for all containers"
}

# Service-specific configuration
variable "server_port" {
  type        = number
  description = "The port the server service listens on"
}

variable "mqtt_broker_port" {
  type        = number
  description = "The MQTT broker port"
}

variable "server_log_configuration" {
  type        = any
  description = "Log configuration for server container"
}

variable "drain_log_configuration" {
  type        = any
  description = "Log configuration for drain container"
}

variable "drain_concurrency" {
  type = object({
    async_jobs      = optional(number, 1)
    async_jobs_fifo = optional(number, 1)
    cronjobs        = optional(number, 1)
    dlq             = optional(number, 1)
    dlq_fifo        = optional(number, 1)
    events          = optional(number, 1)
    iot             = optional(number, 1)
    webhooks        = optional(number, 1)
  })
  description = "Per-queue concurrent receivers for the drain task."
}

variable "scheduler_log_configuration" {
  type        = any
  description = "Log configuration for scheduler container"
}

variable "vcs_gateway_log_configuration" {
  type        = any
  description = "Log configuration for VCS gateway container"
}

variable "vcs_gateway_external_port" {
  type        = number
  description = "External port for VCS gateway"
}

variable "vcs_gateway_internal_port" {
  type        = number
  description = "Internal port for VCS gateway"
}

# Authentication
variable "admin_username" {
  type        = string
  description = "Admin username"
  sensitive   = true
}

variable "admin_password" {
  type        = string
  description = "Admin password"
  sensitive   = true
}

# Webhooks
variable "webhooks_endpoint" {
  type        = string
  description = "Webhooks endpoint URL"
}

# Launcher configuration
variable "launcher_image" {
  type        = string
  description = "Launcher image URL"
}

variable "launcher_image_tag" {
  type        = string
  description = "Launcher image tag"
}

variable "enable_automatic_usage_data_reporting" {
  type        = bool
  description = "Enable automatic usage data reporting"
}

# SQS queues
variable "sqs_queues" {
  type = object({
    deadletter_url      = string
    deadletter_fifo_url = string
    iot_url             = string
  })
  description = "SQS queue URLs"
}

# Secrets
variable "shared_secrets_arn" {
  type        = string
  description = "ARN of the shared secrets"
}

variable "sensitive_env_vars" {
  type = list(object({
    name      = string
    valueFrom = string
  }))
  description = "Sensitive environment variables"
}

# AWS configuration
variable "aws_region" {
  type        = string
  description = "AWS region"
}

# Datadog sidecar configuration
variable "enable_datadog_agent_sidecar" {
  type        = bool
  description = "Enable Datadog agent sidecar"
}

variable "datadog_agent_config" {
  type = object({
    image             = optional(string, "public.ecr.aws/datadog/agent:latest")
    site              = optional(string, "datadoghq.com")
    tags              = optional(list(string), [])
    log_configuration = optional(any)
    stats_port        = optional(number, 8125)
    trace_port        = optional(number, 8126)
    additional_env_vars = optional(list(object({
      name  = string
      value = string
    })), [])
  })
  description = "Datadog agent configuration. If log_configuration is not provided, a default CloudWatch Logs configuration will be used."
}

variable "enable_otel_sidecar" {
  type        = bool
  description = "Enable OpenTelemetry Collector sidecar"
}

variable "otel_config" {
  type = object({
    image = optional(string, "public.ecr.aws/aws-observability/aws-otel-collector:latest")
    # Available config files: https://github.com/aws-observability/aws-otel-collector/tree/v0.46.0/config/ecs
    config_file       = optional(string, "/etc/ecs/ecs-default-config.yaml")
    config_content    = optional(string) # Custom OTEL config content
    log_configuration = optional(any)
    xray_port         = optional(number, 2000)
    otlp_grpc_port    = optional(number, 4317)
    otlp_http_port    = optional(number, 4318)
    additional_env_vars = optional(list(object({
      name  = string
      value = string
    })), [])
  })
  description = "OpenTelemetry Collector configuration. If log_configuration is not provided, a default CloudWatch Logs configuration will be used."
}
