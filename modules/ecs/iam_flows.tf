# The count hangs on var.flows and not on the submodule's output, because that
# one depends on the bucket name, which can be unknown until the bucket exists.
resource "aws_iam_role" "flows" {
  count = var.flows != null ? 1 : 0

  name               = "spacelift-flows-role-${var.suffix}"
  description        = "Role used by Spacelift Flows"
  assume_role_policy = module.iam_roles_and_policies.flows.assume_role
}

resource "aws_iam_policy" "flows" {
  count = var.flows != null ? 1 : 0

  name   = "${aws_iam_role.flows[0].name}-FLOWS"
  policy = module.iam_roles_and_policies.flows.policies["FLOWS"]
}

resource "aws_iam_role_policy_attachment" "flows" {
  count = var.flows != null ? 1 : 0

  role       = aws_iam_role.flows[0].name
  policy_arn = aws_iam_policy.flows[0].arn
}

# On ECS the Flows gateway polls the status of its own task to notice that it is
# being stopped, and shuts down gracefully then. It does not react to SIGTERM.
resource "aws_iam_role_policy" "flows_ecs" {
  count = var.flows != null ? 1 : 0

  name = "ECS"
  role = aws_iam_role.flows[0].name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["ecs:DescribeTasks"]
      Resource = "arn:${var.aws_partition}:ecs:${var.aws_region}:${var.aws_account_id}:task/${aws_ecs_cluster.cluster.name}/*"
    }]
  })
}
