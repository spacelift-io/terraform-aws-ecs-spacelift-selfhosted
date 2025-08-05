output "ecs_cluster_name" {
  value       = aws_ecs_cluster.cluster.name
  description = "The name of the ECS cluster"
}

output "server_service_name" {
  value       = aws_ecs_service.server.name
  description = "The name of the server ECS service"
}

output "drain_service_name" {
  value       = aws_ecs_service.drain.name
  description = "The name of the drain ECS service"
}

output "scheduler_service_name" {
  value       = aws_ecs_service.scheduler.name
  description = "The name of the scheduler ECS service"
}

output "vcs_gateway_service_name" {
  value       = var.vcs_gateway_security_group_id != null ? aws_ecs_service.vcs_gateway[0].name : null
  description = "The name of the VCS gateway ECS service"
}
