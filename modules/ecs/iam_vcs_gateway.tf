resource "aws_iam_role" "vcs_gateway" {
  count = var.vcs_gateway_security_group_id != null ? 1 : 0

  name               = "spacelift-vcs-gateway-role-${var.suffix}"
  description        = "Role used by VCS gateway"
  assume_role_policy = module.iam_roles_and_policies.vcs_gateway.assume_role
}

resource "aws_iam_policy" "vcs_gateway" {
  for_each = var.vcs_gateway_security_group_id != null ? module.iam_roles_and_policies.vcs_gateway.policies : {}

  name   = "${aws_iam_role.vcs_gateway[0].name}-${each.key}"
  policy = each.value
}

resource "aws_iam_role_policy_attachment" "vcs_gateway" {
  for_each = var.vcs_gateway_security_group_id != null ? module.iam_roles_and_policies.vcs_gateway.policies : {}

  role       = aws_iam_role.vcs_gateway[0].name
  policy_arn = aws_iam_policy.vcs_gateway[each.key].arn
}
