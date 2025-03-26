
resource "aws_iam_role" "server" {
  count = var.server_role_arn == null ? 1 : 0

  name               = "spacelift-server-role-${var.suffix}"
  assume_role_policy = module.iam_roles_and_policies.server.assume_role
}

resource "aws_iam_policy" "server" {
  for_each = var.server_role_arn == null ? module.iam_roles_and_policies.server.policies : {}

  name   = "${aws_iam_role.server[0].name}-${each.key}"
  policy = each.value
}

resource "aws_iam_role_policy_attachment" "server" {
  for_each = var.server_role_arn == null ? module.iam_roles_and_policies.server.policies : {}

  role       = aws_iam_role.server[0].name
  policy_arn = aws_iam_policy.server[each.key].arn
}
