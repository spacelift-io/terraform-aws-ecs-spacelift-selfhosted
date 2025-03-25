resource "aws_iam_role" "execution" {
  count = var.execution_role_arn == null ? 1 : 0

  name               = "spacelift-execution-role-${var.suffix}"
  assume_role_policy = module.iam_roles_and_policies.execution.assume_role
}

resource "aws_iam_role_policy" "execution" {
  for_each = var.execution_role_arn == null ? module.iam_roles_and_policies.execution.policies : {}

  name   = "${aws_iam_role.execution[0].name}-${each.key}"
  role   = aws_iam_role.execution[0].name
  policy = each.value
}

resource "aws_iam_role_policy_attachment" "execution" {
  for_each = var.execution_role_arn == null ? module.iam_roles_and_policies.execution.policies : {}

  role       = aws_iam_role.execution[0].name
  policy_arn = aws_iam_role_policy.execution[each.key].arn
}

resource "aws_iam_role_policy_attachment" "execution_extra" {
  for_each = var.execution_role_arn == null ? module.iam_roles_and_policies.execution.attachments : {}

  role       = aws_iam_role.execution[0].name
  policy_arn = each.value
}
