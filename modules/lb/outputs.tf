output "server_lb_dns" {
  value = aws_lb.server.dns_name
}

output "mqtt_lb_dns" {
  value = var.mqtt_broker_type == "builtin" ? aws_lb.mqtt[0].dns_name : null
}

output "server_target_group_arn" {
  value = aws_lb_target_group.server.arn
}

output "mqtt_target_group_arn" {
  value = var.mqtt_broker_type == "builtin" ? aws_lb_target_group.mqtt[0].arn : null
}

output "vcs_gateway_target_group_arn" {
  value = var.vcs_gateway_service_security_group_id != null ? aws_lb_target_group.vcs_gateway[0].arn : null
}

output "vcs_gateway_lb_dns" {
  value = var.vcs_gateway_service_security_group_id != null ? aws_lb.vcs_gateway[0].dns_name : null
}
