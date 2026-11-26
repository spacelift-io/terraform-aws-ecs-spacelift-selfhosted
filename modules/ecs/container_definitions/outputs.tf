output "server_container_definition" {
  description = "JSON-encoded server container definition including sidecars"
  value       = local.default_server_container_definition
}

output "drain_container_definition" {
  description = "JSON-encoded drain container definition including sidecars"
  value       = local.default_drain_container_definition
}

output "vcs_gateway_container_definition" {
  description = "JSON-encoded VCS gateway container definition including sidecars"
  value       = local.default_vcs_gateway_container_definition
}

output "flows_container_definitions" {
  description = "JSON-encoded Spacelift Flows container definitions, keyed by component (server, worker, gateway). Empty when Flows is not deployed."
  value       = local.flows_container_definitions
}
