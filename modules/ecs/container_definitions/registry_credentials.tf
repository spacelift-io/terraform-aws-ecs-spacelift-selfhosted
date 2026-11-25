# The registry credentials only go on images outside ECR. ECR authenticates
# through the execution role, and ECS refuses to register a task definition
# that combines an ECR image with repositoryCredentials.
locals {
  repository_credentials = var.registry_credentials_secret_arn == null ? {} : {
    repositoryCredentials = { credentialsParameter = var.registry_credentials_secret_arn }
  }

  backend_image_is_ecr = strcontains(var.backend_image, ".dkr.ecr")
  flows_image_is_ecr   = var.flows == null ? false : strcontains(var.flows.image, ".dkr.ecr")

  backend_repository_credentials = local.backend_image_is_ecr ? {} : local.repository_credentials
  flows_repository_credentials   = local.flows_image_is_ecr ? {} : local.repository_credentials
}
