resource "aws_iam_role" "execution" {
  count = var.execution_role_arn == null ? 1 : 0

  name = "spacelift-execution-role-${var.suffix}"
  assume_role_policy = jsonencode({
    Version = "2008-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Action    = "sts:AssumeRole"
        Principal = { Service = "ecs-tasks.amazonaws.com" }
      }
    ]
  })
}

resource "aws_iam_role_policy" "execution" {
  count = var.execution_role_arn == null ? 1 : 0
  role  = aws_iam_role.execution[0].name

  policy = jsonencode({
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
        ]
        Resource = [var.kms_key_arn]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "execution" {
  count = var.execution_role_arn == null ? 1 : 0
  role  = aws_iam_role.execution[0].name

  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
