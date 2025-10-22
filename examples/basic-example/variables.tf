variable "region" {
  type = string
}

variable "unique_suffix" {
  type = string
}

variable "spacelift_version" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "server_security_group_id" {
  type = string
}

variable "drain_security_group_id" {
  type = string
}

variable "scheduler_security_group_id" {
  type = string
}

variable "kms_key_arn" {
  type = string
}

variable "kms_encryption_key_arn" {
  type = string
}

variable "kms_signing_key_arn" {
  type = string
}

variable "server_lb_name" {
  type        = string
  description = "The name of the server load balancer."
  default     = null
}

variable "lb_certificate_arn" {
  type = string
}

variable "website_domain" {
  type = string
}

variable "mqtt_broker_endpoint" {
  type = string
}

variable "ecr_backend_repository_url" {
  type = string
}

variable "ecr_launcher_repository_url" {
  type = string
}
