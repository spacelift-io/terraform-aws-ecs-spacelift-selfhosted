module "spacelift" {
  # Since we're using this internally for testing, let's not pin to a specific version.
  source = "github.com/spacelift-io/terraform-aws-spacelift-selfhosted"

  region          = var.aws_region
  rds_engine_mode = "provisioned"
  rds_instance_configuration = {
    "primary" : {
      instance_identifier : "primary"
      instance_class : "db.serverless"
    }
  }

  rds_serverlessv2_scaling_configuration = {
    min_capacity = 0
    max_capacity = 1.0
  }

  rds_delete_protection_enabled = false
  s3_retain_on_destroy          = false
  ecr_force_delete              = true

  website_endpoint = "https://module-test-aws-ecs.spacelift.sh"
}
