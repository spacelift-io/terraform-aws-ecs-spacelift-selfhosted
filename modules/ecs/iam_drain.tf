resource "aws_iam_role" "drain" {
  count = var.drain_role_arn == null ? 1 : 0

  name = "spacelift-drain-role-${var.suffix}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "drain" {
  count = var.drain_role_arn == null ? 1 : 0

  name = "spacelift-drain-${var.suffix}"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:DeleteObject", "s3:ListBucket"]
        Resource = [var.states_bucket_arn, "${var.states_bucket_arn}/*"]
      },
      {
        Effect   = "Allow"
        Action   = ["s3:AbortMultipartUpload", "s3:DeleteObject", "s3:GetObject", "s3:PutObject"]
        Resource = [var.metadata_bucket_arn, "${var.metadata_bucket_arn}/*"]
      },
      {
        Effect   = "Allow"
        Action   = ["s3:AbortMultipartUpload", "s3:DeleteObject", "s3:GetObject", "s3:PutObject"]
        Resource = [var.workspace_bucket_arn, "${var.workspace_bucket_arn}/*"]
      },
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject"]
        Resource = [var.large_queue_messages_arn, "${var.large_queue_messages_arn}/*"]
      },
      {
        Effect   = "Allow"
        Action   = ["s3:PutObjectTagging"]
        Resource = [var.run_logs_bucket_arn, "${var.run_logs_bucket_arn}/*"]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "drain" {
  count = var.drain_role_arn == null ? 1 : 0

  role       = aws_iam_role.drain[0].name
  policy_arn = aws_iam_policy.drain[0].arn
}

resource "aws_iam_role_policy_attachment" "common-policy-for-drain" {
  count = var.drain_role_arn == null && var.server_role_arn == null ? 1 : 0

  role       = aws_iam_role.drain[0].name
  policy_arn = aws_iam_policy.drain-and-server[0].arn
}
