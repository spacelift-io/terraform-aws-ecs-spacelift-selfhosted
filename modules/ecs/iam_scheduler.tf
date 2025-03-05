resource "aws_iam_role" "scheduler" {
  count = var.scheduler_role_arn == null ? 1 : 0

  name        = "spacelift-scheduler-role-${var.suffix}"
  description = "Role used by scheduler"
  assume_role_policy = jsonencode(
    {
      Version = "2012-10-17"
      Statement = [
        {
          Effect    = "Allow"
          Action    = "sts:AssumeRole"
          Principal = { Service = "ecs-tasks.amazonaws.com" }
        }
      ]
    }
  )

}

resource "aws_iam_policy" "scheduler" {
  count = var.scheduler_role_arn == null ? 1 : 0

  name        = "spacelift-scheduler-${var.suffix}"
  description = "Policy used by scheduler"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["cloudwatch:PutMetricData"]
        Resource = ["*"]
      },
      {
        Effect   = "Allow"
        Action   = ["sts:AssumeRole"]
        Resource = ["*"]
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:Encrypt",
          "kms:GenerateDataKey",
        ]
        Resource = [var.kms_key_arn]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "scheduler" {
  count = var.scheduler_role_arn == null ? 1 : 0

  role       = aws_iam_role.scheduler[0].name
  policy_arn = aws_iam_policy.scheduler[0].arn
}
