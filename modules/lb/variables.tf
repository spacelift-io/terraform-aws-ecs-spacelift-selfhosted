variable "suffix" {
  type        = string
  description = "A unique suffix to append to resource names. Ideally passed from the terraform-aws-spacelift-selfhosted module's outputs."
}

variable "vpc_id" {
  type        = string
  description = "The VPC ID to deploy resources in."
}

variable "server_port" {
  type        = number
  description = "The port the server is listening on."
}

variable "mqtt_port" {
  type        = number
  description = "The port the MQTT server is listening on."
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

variable "mqtt_lb_internal" {
  type        = bool
  description = "Whether the MQTT load balancer should be internal or internet-facing."
}
