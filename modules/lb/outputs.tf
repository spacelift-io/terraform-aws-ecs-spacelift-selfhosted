output "server_lb_dns" {
  value = one(aws_lb.server[*].dns_name)
}

output "server_lb_arn" {
  value = one(aws_lb.server[*].arn)
}

output "server_lb_arn_suffix" {
  value = one(aws_lb.server[*].arn_suffix)
}

output "server_lb_name" {
  value = one(aws_lb.server[*].name)
}

output "mqtt_lb_dns" {
  value = one(aws_lb.mqtt[*].dns_name)
}

output "mqtt_lb_arn" {
  value = one(aws_lb.mqtt[*].arn)
}

output "mqtt_lb_arn_suffix" {
  value = one(aws_lb.mqtt[*].arn_suffix)
}

output "mqtt_lb_name" {
  value = one(aws_lb.mqtt[*].name)
}

output "server_target_group_arn" {
  value = one(aws_lb_target_group.server[*].arn)
}

output "mqtt_target_group_arn" {
  value = one(aws_lb_target_group.mqtt[*].arn)
}

output "vcs_gateway_target_group_arn" {
  value = one(aws_lb_target_group.vcs_gateway[*].arn)
}

output "vcs_gateway_lb_dns" {
  value = one(aws_lb.vcs_gateway[*].dns_name)
}

output "load_balancer_security_group_id" {
  value       = local.load_balancer_security_group_id
  description = "The security group ID used by the main load balancer (either provided or created)"
}
