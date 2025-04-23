resource "aws_secretsmanager_secret" "shared_secrets" {
  name        = "spacelift/shared-secrets-${var.suffix}"
  description = "Secrets that are used by the Spacelift ECS services"
}

resource "aws_secretsmanager_secret_version" "shared_secrets" {
  secret_id     = aws_secretsmanager_secret.shared_secrets.id
  secret_string = jsonencode({ LICENSE_TOKEN = var.license_token })
}
