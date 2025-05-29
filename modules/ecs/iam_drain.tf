resource "aws_iam_role" "drain" {
  count = var.drain_role_arn == null ? 1 : 0

  name               = "spacelift-drain-role-${var.suffix}"
  assume_role_policy = module.iam_roles_and_policies.drain.assume_role

  permissions_boundary = var.permissions_boundary
}

resource "aws_iam_policy" "drain_role" {
  for_each = var.drain_role_arn == null ? module.iam_roles_and_policies.drain.policies : {}

  name   = "${aws_iam_role.drain[0].name}-${each.key}"
  policy = each.value
}

resource "aws_iam_role_policy_attachment" "drain_role" {
  for_each = var.drain_role_arn == null ? module.iam_roles_and_policies.drain.policies : {}

  role       = aws_iam_role.drain[0].name
  policy_arn = aws_iam_policy.drain_role[each.key].arn
}
