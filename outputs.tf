output "server_lb_dns_name" {
  value       = module.lb.server_lb_dns
  description = "The DNS name of the server load balancer"
}

output "mqtt_lb_dns_name" {
  value       = module.lb.mqtt_lb_dns
  description = "The DNS name of the mqtt load balancer"
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
