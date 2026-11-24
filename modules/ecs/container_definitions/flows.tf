# Spacelift Flows runs as three services from one image: the server, the worker
# and the gateway the agents connect to. They share the same configuration.

locals {
  flows_container_definitions = var.flows == null ? {} : {
    for component in ["server", "worker", "gateway"] : component => jsonencode([
      merge(
        {
          name      = "flows-${component}"
          command   = ["/usr/bin/spacelift-flows", component]
          essential = true
          image     = var.flows.image
          portMappings = concat(
            [
              {
                containerPort = var.flows.port
              }
            ],
            component == "gateway" ? [
              {
                containerPort = var.flows.gateway_internal_port
              }
            ] : []
          )
          linuxParameters = {
            initProcessEnabled = true
          }
          logConfiguration = var.flows.log_configuration
          environment      = var.flows.environment
          secrets          = var.flows.secrets
        },
        var.registry_credentials_secret_arn != null ? {
          repositoryCredentials = { credentialsParameter = var.registry_credentials_secret_arn }
        } : {}
      )
    ])
  }
}
