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

output "vcs_gateway_service_name" {
  value       = one(aws_ecs_service.vcs_gateway[*].name)
  description = "The name of the VCS gateway ECS service"
}

output "registry_credentials_secret_arn" {
  value       = local.registry_credentials_secret_arn
  description = "The ARN of the Secrets Manager secret with the registry credentials"
}
