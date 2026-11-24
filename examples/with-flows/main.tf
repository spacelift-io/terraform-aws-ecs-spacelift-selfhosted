module "spacelift_infra" {
  source  = "spacelift-io/spacelift-selfhosted/aws"
  version = "~> 3.5"

  region             = "us-east-1"
  website_endpoint   = "https://deploy.spacelift.io"
  rds_engine_version = "18.6"

  enable_flows = true
}

module "spacelift_services" {
  source = "../../"

  # The rest of the configuration is the same as without Flows, see the README of the module.

  flows = {
    domain            = "flows.spacelift.io"
    certificate_arn   = "arn:aws:acm:us-east-1:123456789012:certificate/abc123"
    organization_name = "Spacelift"
    admin_email       = "admin@spacelift.io"
    admin_password    = "<your-admin-password>"
    database_url      = module.spacelift_infra.flows_database_url
    bucket_name       = module.spacelift_infra.flows_bucket_name
    kms_key_arn       = module.spacelift_infra.flows_kms_key_arn
    lb_subnets        = module.spacelift_infra.public_subnet_ids
  }
}
