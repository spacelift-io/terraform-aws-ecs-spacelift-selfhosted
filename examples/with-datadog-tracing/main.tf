module "spacelift" {
  source  = "spacelift-io/ecs-spacelift-selfhosted/aws"
  version = "~> 3.1"

  # ... other required variables ...

  # Observability configuration
  enable_datadog_agent_sidecar = true
  datadog_api_key              = var.datadog_api_key
  datadog_agent_config = {
    image = "public.ecr.aws/datadog/agent:7"
    site  = var.datadog_site
    tags  = ["env:selfhosted", "service:spacelift"]
    log_configuration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = "/aws/ecs/datadog-agent"
        "awslogs-region"        = var.region
        "awslogs-create-group"  = "true"
        "awslogs-stream-prefix" = "datadog"
      }
    }
  }
}
