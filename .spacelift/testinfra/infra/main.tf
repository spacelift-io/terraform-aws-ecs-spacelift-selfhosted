data "aws_rds_engine_version" "pgversion" {
  engine = "aurora-postgresql"
  latest = true

  filter {
    name   = "engine-mode"
    values = ["provisioned"]
  }
}

module "spacelift" {
  # Since we're using this internally for testing, let's not pin to a specific version.
  source = "github.com/spacelift-io/terraform-aws-spacelift-selfhosted"

  region             = var.aws_region
  rds_engine_version = data.aws_rds_engine_version.pgversion.version_actual
  rds_engine_mode    = "provisioned"
  rds_instance_configuration = {}

  rds_delete_protection_enabled = false
  s3_retain_on_destroy          = false
  ecr_force_delete              = true

  website_endpoint = "https://module-test-aws-ecs.spacelift.sh"
}
