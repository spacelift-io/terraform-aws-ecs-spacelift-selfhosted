
resource "aws_iam_role" "server" {
  count = var.server_role_arn == null ? 1 : 0

  name = "spacelift-server-role-${var.suffix}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Action    = "sts:AssumeRole"
        Principal = { Service = "ecs-tasks.amazonaws.com" }
      }
    ]
  })
}

resource "aws_iam_policy" "server" {
  count = var.server_role_arn == null ? 1 : 0

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:AbortMultipartUpload", "s3:DeleteObject", "s3:GetObject", "s3:ListBucket", "s3:PutObject", "s3:PutObjectTagging", "s3:GetObjectVersion", "s3:ListBucketVersions"]
        Resource = [var.states_bucket_arn, "${var.states_bucket_arn}/*"]
      },
      {
        Effect   = "Allow"
        Action   = ["s3:AbortMultipartUpload", "s3:DeleteObject", "s3:GetObject", "s3:PutObject"]
        Resource = [var.uploads_bucket_arn, "${var.uploads_bucket_arn}/*"]
      },
      {
        Effect   = "Allow"
        Action   = ["s3:AbortMultipartUpload", "s3:PutObject"]
        Resource = [var.large_queue_messages_bucket_arn, "${var.large_queue_messages_bucket_arn}/*"]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "server" {
  count = var.server_role_arn == null ? 1 : 0

  role       = aws_iam_role.server[0].name
  policy_arn = aws_iam_policy.server[0].arn
}

resource "aws_iam_policy" "drain-and-server" {
  # Assuming that both are either null or provided
  count = var.drain_role_arn == null && var.server_role_arn == null ? 1 : 0

  name        = "spacelift-drain-and-server-${var.suffix}"
  description = "Policy shared by drain and server"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat([
      {
        Effect   = "Allow"
        Action   = ["cloudwatch:PutMetricData"],
        Resource = ["*"],
      },
      {
        Effect   = "Allow"
        Action   = ["sts:AssumeRole"],
        Resource = ["*"],
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket",
          "s3:PutObject",
        ],
        Resource = [
          var.deliveries_bucket_arn,
          "${var.deliveries_bucket_arn}/*",
        ],
      },
      {
        Effect = "Allow"
        Action = [
          "s3:AbortMultipartUpload",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:PutObject",
        ],
        Resource = [
          var.policy_inputs_bucket_arn,
          "${var.policy_inputs_bucket_arn}/*",
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "s3:AbortMultipartUpload",
          "s3:DeleteObject",
          "s3:GetObject",
          "s3:PutObject",
        ],
        Resource = [
          var.user_uploaded_workspaces_arn,
          "${var.user_uploaded_workspaces_arn}/*",
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ],
        Resource = [
          var.run_logs_bucket_arn,
          "${var.run_logs_bucket_arn}/*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "s3:AbortMultipartUpload",
          "s3:PutObject"
        ],
        Resource = [
          var.run_logs_bucket_arn,
          "${var.run_logs_bucket_arn}/*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "s3:DeleteObject",
          "s3:GetObject",
          "s3:ListBucket",
        ],
        Resource = [
          var.modules_bucket_arn,
          "${var.modules_bucket_arn}/*",
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "s3:AbortMultipartUpload",
          "s3:PutObject"
        ],
        Resource = [
          var.modules_bucket_arn,
          "${var.modules_bucket_arn}/*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "kms:Decrypt",
          "kms:Encrypt",
          "kms:GenerateDataKey",
        ],
        Resource = [var.kms_key_arn]
      }
      ], var.encryption_kms_encryption_key_id == null ? [] : [{
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:Encrypt",
          "kms:GenerateDataKey",
        ]
        Resource = [var.encryption_kms_encryption_key_id]
    }])
  })
}
resource "aws_iam_role_policy_attachment" "common-policy-for-server" {
  count = var.drain_role_arn == null && var.server_role_arn == null ? 1 : 0

  role       = aws_iam_role.server[0].name
  policy_arn = aws_iam_policy.drain-and-server[0].arn
}

