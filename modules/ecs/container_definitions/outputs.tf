output "server_container_definition" {
  description = "JSON-encoded server container definition including sidecars"
  value       = local.default_server_container_definition
}

output "drain_container_definition" {
  description = "JSON-encoded drain container definition including sidecars"
  value       = local.default_drain_container_definition
}

output "scheduler_container_definition" {
  description = "JSON-encoded scheduler container definition including sidecars"
  value       = local.default_scheduler_container_definition
}

output "vcs_gateway_container_definition" {
  description = "JSON-encoded VCS gateway container definition including sidecars"
  value       = local.default_vcs_gateway_container_definition
}
