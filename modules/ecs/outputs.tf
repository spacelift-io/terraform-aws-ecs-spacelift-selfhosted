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

output "flows_service_names" {
  value       = { for component, service in aws_ecs_service.flows : component => service.name }
  description = "The names of the Spacelift Flows ECS services, keyed by component (server, worker, gateway). Empty when Flows is not deployed."
}

output "flows_agent_pool_id" {
  value       = one(random_uuid.flows_default_agent_pool_id[*].result)
  description = "The ID of the default Spacelift Flows agent pool"
}

output "flows_agent_pool_token_secret_arn" {
  value       = one(aws_secretsmanager_secret.flows_agent_pool_token[*].arn)
  description = "The ARN of the Secrets Manager secret with the token of the default Spacelift Flows agent pool"
}

output "registry_credentials_secret_arn" {
  value       = local.registry_credentials_secret_arn
  description = "The ARN of the Secrets Manager secret with the registry credentials"
}
