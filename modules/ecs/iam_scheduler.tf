resource "aws_iam_role" "scheduler" {
  count = var.scheduler_role_arn == null ? 1 : 0

  name               = "spacelift-scheduler-role-${var.suffix}"
  description        = "Role used by scheduler"
  assume_role_policy = module.iam_roles_and_policies.scheduler.assume_role

  permissions_boundary = var.permissions_boundary
}

resource "aws_iam_policy" "scheduler" {
  for_each = var.scheduler_role_arn == null ? module.iam_roles_and_policies.scheduler.policies : {}

  name   = "${aws_iam_role.scheduler[0].name}-${each.key}"
  policy = each.value
}

resource "aws_iam_role_policy_attachment" "scheduler" {
  for_each = var.scheduler_role_arn == null ? module.iam_roles_and_policies.scheduler.policies : {}

  role       = aws_iam_role.scheduler[0].name
  policy_arn = aws_iam_policy.scheduler[each.key].arn
}
