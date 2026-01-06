provider "aws" {
  region = var.region

  default_tags {
    tags = {
      TfModule   = "terraform-aws-ecs-spacelift-selfhosted"
      Repository = "https://github.com/spacelift-io/terraform-aws-ecs-spacelift-selfhosted"
      TestCase   = "WithOtelToGrafanaCloudTracing"
    }
  }
}
