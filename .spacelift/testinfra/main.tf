locals {
  aws_region_for_module_tests = "eu-central-1"
}

resource "spacelift_stack" "aws-module-test-infra" {
  name                    = "Self-Hosted AWS ECS Terraform Module Test Infrastructure"
  description             = "Deploys a base infrastructure that can be used in the test cases of the https://github.com/spacelift-io/terraform-aws-ecs-spacelift-selfhosted module."
  autodeploy              = true
  branch                  = "main"
  project_root            = ".spacelift/testinfra/infra"
  repository              = "terraform-aws-ecs-spacelift-selfhosted"
  terraform_workflow_tool = "OPEN_TOFU"
  terraform_version       = "> 1.8.0"
  space_id                = "self-hosted-v3-01JA7SJMJW7PNYQAQAD05DSKGX"
  labels                  = ["folder:SelfHosted"]
}

resource "spacelift_aws_integration_attachment" "aws-moduletest-infra" {
  integration_id = data.spacelift_aws_integration.aws.integration_id
  stack_id       = spacelift_stack.aws-module-test-infra.id
  read           = true
  write          = true
}

resource "spacelift_environment_variable" "aws-moduletest-infra-aws_region" {
  stack_id   = spacelift_stack.aws-infra.id
  name       = "TF_VAR_aws_region"
  value      = local.aws_region_for_module_tests
  write_only = false
}

resource "spacelift_stack_destructor" "aws-moduletest-infra" {
  depends_on = [
    spacelift_aws_integration_attachment.aws-moduletest-infra,
    spacelift_environment_variable.aws-moduletest-infra-aws_region,
  ]

  stack_id = spacelift_stack.aws-module-test-infra.id
}
