output "server_lb_dns_name" {
  value       = module.lb.server_lb_dns
  description = "The DNS name of the server load balancer"
}

output "server_lb_arn" {
  value       = module.lb.server_lb_arn
  description = "The ARN of the server load balancer"
}

output "server_lb_arn_suffix" {
  value       = module.lb.server_lb_arn_suffix
  description = "The ARN suffix of the server load balancer for use with CloudWatch"
}

output "server_lb_name" {
  value       = module.lb.server_lb_name
  description = "The name of the server load balancer"
}

output "mqtt_lb_dns_name" {
  value       = module.lb.mqtt_lb_dns
  description = "The DNS name of the mqtt load balancer"
}

output "mqtt_lb_arn" {
  value       = module.lb.mqtt_lb_arn
  description = "The ARN of the mqtt load balancer"
}

output "mqtt_lb_arn_suffix" {
  value       = module.lb.mqtt_lb_arn_suffix
  description = "The ARN suffix of the mqtt load balancer for use with CloudWatch"
}

output "mqtt_lb_name" {
  value       = module.lb.mqtt_lb_name
  description = "The name of the mqtt load balancer"
}

output "vcs_gateway_lb_dns_name" {
  value       = module.lb.vcs_gateway_lb_dns
  description = "The DNS name of the VCS gateway load balancer"
}

output "ecs_cluster_name" {
  value       = module.ecs.ecs_cluster_name
  description = "The name of the ECS cluster"
}

output "server_service_name" {
  value       = module.ecs.server_service_name
  description = "The name of the server ECS service"
}

output "drain_service_name" {
  value       = module.ecs.drain_service_name
  description = "The name of the drain ECS service"
}

output "vcs_gateway_service_name" {
  value       = module.ecs.vcs_gateway_service_name
  description = "The name of the VCS gateway ECS service"
}

output "flows_lb_dns_name" {
  value       = module.lb.flows_lb_dns
  description = "The DNS name of the Spacelift Flows load balancer. Null when Flows is not deployed."
}

output "flows_service_names" {
  value       = module.ecs.flows_service_names
  description = "The names of the Spacelift Flows ECS services, keyed by component (server, worker, gateway). Empty when Flows is not deployed."
}

output "flows_agent_pool_id" {
  value       = module.ecs.flows_agent_pool_id
  description = "ID of the default Flows agent pool, for configuring the Flows agents. Null when Flows is not deployed."
}

output "flows_agent_pool_token_secret_arn" {
  value       = module.ecs.flows_agent_pool_token_secret_arn
  description = "ARN of the Secrets Manager secret with the token of the default Flows agent pool, for configuring the Flows agents. Null when Flows is not deployed."
}

output "registry_credentials_secret_arn" {
  value       = module.ecs.registry_credentials_secret_arn
  description = "The ARN of the Secrets Manager secret with the registry credentials. Null when neither registry_credentials nor byo_registry_credentials_secret is set."
}
