terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      app                = "spacelift-selfhosted"
      endpoint           = "module-test-aws-ecs.spacelift.sh"
      repo               = "github.com/spacelift-io/selfhosted"
      purpose            = "Serves as a base infra for module test cases"
      spacelift_stack_id = var.spacelift_stack_id
    }
  }
}
