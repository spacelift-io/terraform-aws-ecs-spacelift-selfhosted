variable "suffix" {
  type        = string
  description = "A unique suffix to append to resource names. Ideally passed from the terraform-aws-spacelift-selfhosted module's outputs."
}

variable "vpc_id" {
  type        = string
  description = "The VPC ID to deploy resources in."
}

variable "drain_security_group_id" {
  type        = string
  description = "The security group ID for the drain service."
}

variable "server_security_group_id" {
  type        = string
  description = "The security group ID for the server."
}

variable "server_port" {
  type        = number
  description = "The port the server is listening on."
}

variable "server_lb_name" {
  type        = string
  description = "The name of the server load balancer."
  default     = null
}

variable "server_lb_subnets" {
  type        = list(string)
  description = "The subnets to deploy the server load balancer in."
}

variable "server_lb_internal" {
  type        = bool
  description = "Whether the server load balancer should be internal or internet-facing."
}

variable "server_lb_certificate_arn" {
  type        = string
  description = "The ARN of the certificate to use for the server load balancer."
}

variable "mqtt_lb_subnets" {
  type        = list(string)
  description = "The subnets to deploy the MQTT load balancer in."
}

variable "mqtt_port" {
  type        = number
  description = "The port the MQTT server is listening on."
}

variable "mqtt_lb_internal" {
  type        = bool
  description = "Whether the MQTT load balancer should be internal or internet-facing."
}

variable "mqtt_broker_type" {
  type        = string
  description = "The type of MQTT broker to use (builtin or iotcore)."
}

variable "vcs_gateway_service_security_group_id" {
  type        = string
  description = "The security group ID to use for the VCS gateway service."
}

variable "vcs_gateway_external_port" {
  type        = number
  description = "The external port for the VCS gateway service. Used by remote agents to connect."
}

variable "vcs_gateway_internal_port" {
  type        = number
  description = "The internal port for the VCS gateway service. Used by the server and the drain to connect to the VCS gateway."
}

variable "vcs_gateway_internal" {
  type        = bool
  description = "Whether the VCS gateway load balancer should be internal or internet-facing."
}

variable "vcs_gateway_lb_subnets" {
  type        = list(string)
  description = "The subnets to deploy the VCS gateway load balancer in."
}

variable "vcs_gateway_certificate_arn" {
  type        = string
  description = "The ARN of the certificate to use for the VCS gateway load balancer."
}

variable "load_balancer_security_group_id" {
  type        = string
  default     = null
  description = "The security group ID to use for the main load balancer. If not provided, a new security group will be created."
}
