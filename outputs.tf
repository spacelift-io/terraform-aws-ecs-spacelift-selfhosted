output "server_lb_dns_name" {
  value       = module.lb.server_lb_dns
  description = "The DNS name of the server load balancer"
}

output "server_lb_arn" {
  value       = module.lb.server_lb_arn
  description = "The ARN of the server load balancer"
}

output "mqtt_lb_dns_name" {
  value       = module.lb.mqtt_lb_dns
  description = "The DNS name of the mqtt load balancer"
}

output "vcs_gateway_lb_dns_name" {
  value       = module.lb.vcs_gateway_lb_dns
  description = "The DNS name of the VCS gateway load balancer"
}

output "server_service_name" {
  value       = module.ecs.server_service_name
  description = "The name of the server ECS service"
}

output "drain_service_name" {
  value       = module.ecs.drain_service_name
  description = "The name of the drain ECS service"
}

output "scheduler_service_name" {
  value       = module.ecs.scheduler_service_name
  description = "The name of the scheduler ECS service"
}

output "vcs_gateway_service_name" {
  value       = module.ecs.vcs_gateway_service_name
  description = "The name of the VCS gateway ECS service"
}
