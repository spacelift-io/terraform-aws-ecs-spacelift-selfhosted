# ☁️ Terraform module for Spacelift on AWS, based on ECS

This module creates an ECS cluster with all the necessary resources to run Spacelift self-hosted on AWS.

This module is closely tied to the [terraform-aws-spacelift-selfhosted](https://github.com/spacelift-io/terraform-aws-spacelift-selfhosted) module, which contains the necessary surrounding infrastructure.

## State storage

Check out the [Terraform](https://developer.hashicorp.com/terraform/language/backend) or the [OpenTofu](https://opentofu.org/docs/language/settings/backends/configuration/) backend documentation for more information on how to configure the state storage.

> ⚠️ Do **not** import the state into Spacelift after the installation: that would cause circular dependencies, and in case you accidentally break the Spacelift installation, you wouldn't be able to fix it.

## ✨ Usage

```hcl
locals {
  spacelift_version = "v3.4.0"
  website_domain    = "https://spacelift.mycorp.io"
}

module "spacelift_infra" {
  source = "github.com/spacelift-io/terraform-aws-spacelift-selfhosted?ref=v1.0.0"

  region         = "eu-west-1"
  default_tags   = {"app" = "spacelift-selfhosted-infra", "env" = "dev"}
  website_domain = local.website_domain
}

module "spacelift_services" {
  source = "github.com/spacelift-io/terraform-aws-ecs-spacelift-selfhosted?ref=v1.0.0"

  region        = "eu-west-1"
  default_tags  = {"app" = "spacelift-selfhosted-services", "env" = "dev"}
  unique_suffix = module.spacelift_infra.unique_suffix
  kms_key_arn   = module.spacelift_infra.kms_key_arn
  server_domain = local.website_domain

  license_token = "<your-license-token-issued-by-Spacelift>"

  encryption_type                  = "kms"
  encryption_kms_encryption_key_id = module.spacelift_infra.encryption_key_arn

  database_url           = format("postgres://%s:%s@%s:5432/spacelift?statement_cache_capacity=0", module.spacelift_infra.rds_username, module.spacelift_infra.rds_password, module.spacelift_infra.rds_cluster_endpoint)
  database_read_only_url = format("postgres://%s:%s@%s:5432/spacelift?statement_cache_capacity=0", module.spacelift_infra.rds_username, module.spacelift_infra.rds_password, module.spacelift_infra.rds_cluster_reader_endpoint)

  backend_image      = "${module.spacelift_infra.ecr_backend_repository_url}:${local.spacelift_version}"
  launcher_image     = module.spacelift_infra.ecr_launcher_repository_url
  launcher_image_tag = local.spacelift_version

  admin_username = "admin"      # Temporary for the initial setup, will be removed
  admin_password = "1P@ssw0rd"  # Temporary for the initial setup, will be removed

  vpc_id  = module.spacelift_infra.vpc_id
  subnets = module.spacelift_infra.private_subnet_ids

  server_lb_subnets           = module.spacelift_infra.private_subnet_ids
  server_lb_security_group_id = module.spacelift_infra.server_security_group_id
  server_security_group_id    = module.spacelift_infra.server_security_group_id

  scheduler_security_group_id = module.spacelift_infra.scheduler_security_group_id

  mqtt_lb_subnets = module.spacelift_infra.private_subnet_ids

  deliveries_bucket_arn                = module.spacelift_infra.deliveries_bucket_arn
  deliveries_bucket_name               = module.spacelift_infra.deliveries_bucket_name
  large_queue_messages_arn             = module.spacelift_infra.large_queue_messages_arn
  large_queue_messages_bucket_name     = module.spacelift_infra.large_queue_messages_bucket_name
  metadata_bucket_arn                  = module.spacelift_infra.metadata_bucket_arn
  metadata_bucket_name                 = module.spacelift_infra.metadata_bucket_name
  modules_bucket_arn                   = module.spacelift_infra.modules_bucket_arn
  modules_bucket_name                  = module.spacelift_infra.modules_bucket_name
  policy_inputs_bucket_arn             = module.spacelift_infra.policy_inputs_bucket_arn
  policy_inputs_bucket_name            = module.spacelift_infra.policy_inputs_bucket_name
  run_logs_bucket_arn                  = module.spacelift_infra.run_logs_bucket_arn
  run_logs_bucket_name                 = module.spacelift_infra.run_logs_bucket_name
  state_bucket_arn                     = module.spacelift_infra.state_bucket_arn
  state_bucket_name                    = module.spacelift_infra.state_bucket_name
  uploads_bucket_arn                   = module.spacelift_infra.uploads_bucket_arn
  uploads_bucket_name                  = module.spacelift_infra.uploads_bucket_name
  uploads_bucket_url                   = module.spacelift_infra.uploads_bucket_url
  user_uploaded_workspaces_arn         = module.spacelift_infra.user_uploaded_workspaces_arn
  user_uploaded_workspaces_bucket_name = module.spacelift_infra.user_uploaded_workspaces_bucket_name
  workspace_bucket_arn                 = module.spacelift_infra.workspace_bucket_arn
  workspace_bucket_name                = module.spacelift_infra.workspace_bucket_name
}
```

This module creates:

- Load balancers
  - An ALB for the Spacelift server
  - A network load balancer for the MQTT broker
  - A security group for the load balancers
- ECS
  - An ECS cluster
  - Three services (server, drain, scheduler)
  - IAM roles and policies for the corresponding services

### Deploy with existing IAM roles

```hcl
module "spacelift_services" {
  source = "github.com/spacelift-io/terraform-aws-ecs-spacelift-selfhosted?ref=v1.0.0"

  execution_role_arn = aws_iam_role.execution_role.arn
  server_role_arn    = aws_iam_role.spacelift_server_role.arn
  drain_role_arn     = aws_iam_role.spacelift_drain_role.arn
  scheduler_role_arn = aws_iam_role.spacelift_scheduler_role.arn

  # Further configuration removed for brevity
}

resource "aws_iam_role" "execution_role" {
  name = "spacelift-execution-role"
  # Further configuration removed for brevity
}

resource "aws_iam_role" "spacelift_server_role" {
  name = "spacelift-server-role"
  # Further configuration removed for brevity
}

resource "aws_iam_role" "spacelift_drain_role" {
  name = "spacelift-drain-role"
  # Further configuration removed for brevity
}

resource "aws_iam_role" "spacelift_scheduler_role" {
  name = "spacelift-scheduler-role"
  # Further configuration removed for brevity
}
```

## 🚀 Release

We have a [GitHub workflow](./.github/workflows/release.yaml) to automatically create a tag and a release based on the version number in [`.spacelift/config.yml`](./.spacelift/config.yml) file.

When you're ready to release a new version, just simply bump the version number in the config file and open a pull request. Once the pull request is merged, the workflow will create a new release.