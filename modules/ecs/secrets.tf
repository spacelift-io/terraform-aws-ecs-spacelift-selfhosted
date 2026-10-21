resource "aws_secretsmanager_secret" "shared_secrets" {
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
  region           = var.aws_region
  secret_id        = aws_secretsmanager_secret.shared_secrets.id
  secret_string_wo = local.payload

  secret_string_wo_version = local.version_num
}

locals {
  # count rejects sensitive values. Whether the credentials are set is not a secret.
  registry_credentials_enabled = nonsensitive(var.registry_credentials != null)

  # repositoryCredentials needs a secret with exactly the username and password keys.
  registry_credentials_payload = jsonencode(var.registry_credentials)
}

resource "aws_secretsmanager_secret" "registry_credentials" {
  count = local.registry_credentials_enabled ? 1 : 0

  name                    = "spacelift/registry-credentials-${var.suffix}"
  region                  = var.aws_region
  description             = "Credentials the Spacelift ECS services use to pull the backend image"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "registry_credentials" {
  count = local.registry_credentials_enabled ? 1 : 0

  region           = var.aws_region
  secret_id        = aws_secretsmanager_secret.registry_credentials[0].id
  secret_string_wo = local.registry_credentials_payload

  secret_string_wo_version = parseint(substr(sha256(local.registry_credentials_payload), 0, 8), 16)
}
