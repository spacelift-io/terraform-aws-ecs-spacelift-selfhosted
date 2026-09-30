resource "aws_secretsmanager_secret" "shared_secrets" {
  count = var.shared_secrets != null ? 1 : 0

  name                    = "spacelift/shared-secrets-${var.suffix}"
  region                  = var.aws_region
  description             = "Secrets that are used by the Spacelift ECS services"
  recovery_window_in_days = 0
}

locals {
  payload = jsonencode({
    LICENSE_TOKEN      = try(tostring(var.license_token), "")
    DD_API_KEY         = try(tostring(var.datadog_api_key), "")
    AOT_CONFIG_CONTENT = try(tostring(var.otel_config.config_content), "")
  })

  # take 32 bits from sha256 and turn into a number
  version_hex = substr(sha256(local.payload), 0, 8)
  version_num = parseint(local.version_hex, 16)
}

resource "aws_secretsmanager_secret_version" "shared_secrets" {
  count = var.shared_secrets != null ? 1 : 0

  region = var.aws_region

  secret_id        = aws_secretsmanager_secret.shared_secrets[0].id
  secret_string_wo = local.payload

  secret_string_wo_version = local.version_num
}

locals {
  # count rejects sensitive values. Whether the credentials are set is not a secret.
  create_registry_credentials_secret = nonsensitive(var.registry_credentials != null)

  # repositoryCredentials needs a secret with exactly the username and password keys.
  registry_credentials_payload     = jsonencode(var.registry_credentials)
  registry_credentials_version_num = parseint(substr(sha256(local.registry_credentials_payload), 0, 8), 16)

  # Known at plan time even when the BYO secret's ARN is not.
  use_registry_credentials = local.create_registry_credentials_secret || var.byo_registry_credentials_secret != null

  # Null when the image is pulled without credentials.
  registry_credentials_secret_arn = local.create_registry_credentials_secret ? aws_secretsmanager_secret.registry_credentials[0].arn : try(var.byo_registry_credentials_secret.arn, null)

  # The ARN of the shared secrets, either supplied by the caller, or created in this module
  shared_secrets_arn = var.shared_secrets != null ? var.shared_secrets.arn : aws_secretsmanager_secret.shared_secrets[0].arn
}

resource "aws_secretsmanager_secret" "registry_credentials" {
  count = local.create_registry_credentials_secret ? 1 : 0

  name                    = "spacelift/registry-credentials-${var.suffix}"
  region                  = var.aws_region
  description             = "Credentials the Spacelift ECS services use to pull the backend image"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "registry_credentials" {
  count = local.create_registry_credentials_secret ? 1 : 0

  region           = var.aws_region
  secret_id        = aws_secretsmanager_secret.registry_credentials[0].id
  secret_string_wo = local.registry_credentials_payload

  secret_string_wo_version = local.registry_credentials_version_num
}
