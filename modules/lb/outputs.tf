output "server_lb_dns" {
  value = aws_lb.server.dns_name
}

output "mqtt_lb_dns" {
  value = aws_lb.mqtt.dns_name
}

output "server_target_group_arn" {
  value = aws_lb_target_group.server.arn
}

output "mqtt_target_group_arn" {
  value = aws_lb_target_group.mqtt.arn
}
