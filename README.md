# ☁️ Terraform module for Spacelift on AWS, based on ECS

This module creates an ECS cluster with all the necessary resources to run Spacelift self-hosted on AWS.

This module is closely tied to the [terraform-aws-spacelift-selfhosted](https://github.com/spacelift-io/terraform-aws-spacelift-selfhosted) repository, which contains the necessary surrounding infrastructure.

## State storage

Check out the [Terraform](https://developer.hashicorp.com/terraform/language/backend) or the [OpenTofu](https://opentofu.org/docs/language/settings/backends/configuration/) backend documentation for more information on how to configure the state storage.

> ⚠️ Do **not** import the state into Spacelift after the installation: that would cause circular dependencies, and in case you accidentally break the Spacelift installation, you wouldn't be able to fix it.

## ✨ Usage

```hcl
module "spacelift" {
  source = "github.com/spacelift-io/terraform-aws-ecs-spacelift-selfhosted?ref=v1.0.0"

  region       = "eu-west-1"
  default_tags = {"app" = "spacelift-selfhosted"}
}
```

This module creates:

- ECS
  - tbd

### Examples

#### Default

This deploys a KMS key, VPC (subnets, security groups), RDS cluster, ECR repositories and S3 buckets.

```hcl
module "spacelift-ecs" {
  source = "github.com/spacelift-io/terraform-aws-ecs-spacelift-selfhosted?ref=v1.0.0"

  # Test
}
```

### Deploy with an existing VPC

```hcl
module "spacelift-ecs" {
  source = "github.com/spacelift-io/terraform-aws-ecs-spacelift-selfhosted?ref=v1.0.0"

  # Test
}
```
## 🚀 Release

We have a [GitHub workflow](./.github/workflows/release.yaml) to automatically create a tag and a release based on the version number in [`.spacelift/config.yml`](./.spacelift/config.yml) file.

When you're ready to release a new version, just simply bump the version number in the config file and open a pull request. Once the pull request is merged, the workflow will create a new release.