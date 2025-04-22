# ☁️ Terraform module for Spacelift on AWS, based on ECS

This module creates an ECS cluster with all the necessary resources to run Spacelift self-hosted on AWS.

This module is closely tied to the [terraform-aws-spacelift-selfhosted](https://github.com/spacelift-io/terraform-aws-spacelift-selfhosted) module, which contains the necessary surrounding infrastructure.

## State storage

Check out the [Terraform](https://developer.hashicorp.com/terraform/language/backend) or the [OpenTofu](https://opentofu.org/docs/language/settings/backends/configuration/) backend documentation for more information on how to configure the state storage.

> ⚠️ Do **not** import the state into Spacelift after the installation: that would cause circular dependencies, and in case you accidentally break the Spacelift installation, you wouldn't be able to fix it.

## ✨ Usage

```hcl
locals {
  region            = "eu-west-1"
  spacelift_version = "v3.4.0"
  website_domain    = "spacelift.mycorp.io"
  website_endpoint  = "https://${local.website_domain}"
  mqtt_domain       = "spacelift-mqtt.mycorp.io"
  mqtt_endpoint     = "tls://${local.mqtt_domain}:1984"
}

module "spacelift_infra" {
  source = "github.com/spacelift-io/terraform-aws-spacelift-selfhosted?ref=v1.2.0"

  region           = local.region
  website_endpoint = local.website_endpoint
}

module "spacelift_services" {
  source = "github.com/spacelift-io/terraform-aws-ecs-spacelift-selfhosted?ref=v1.1.0"

  region               = local.region
  unique_suffix        = module.spacelift_infra.unique_suffix
  kms_key_arn          = module.spacelift_infra.kms_key_arn
  server_domain        = local.website_domain
  mqtt_broker_endpoint = local.mqtt_endpoint

  license_token = "<your-license-token-issued-by-Spacelift>"

  encryption_type        = "kms"
  kms_encryption_key_arn = module.spacelift_infra.kms_encryption_key_arn
  kms_signing_key_arn    = module.spacelift_infra.kms_signing_key_arn

  secrets_manager_secret_arns = [module.spacelift_infra.database_secret_arn]
  sensitive_env_vars          = [
    {
      name = "DATABASE_URL"
      valueFrom = "${module.spacelift_infra.database_secret_arn}:DATABASE_URL::"
    },
    {
      name = "DATABASE_READ_ONLY_URL"
      valueFrom = "${module.spacelift_infra.database_secret_arn}:DATABASE_READ_ONLY_URL::"
    }
  ]

  backend_image      = module.spacelift_infra.ecr_backend_repository_url
  backend_image_tag  = local.spacelift_version
  launcher_image     = module.spacelift_infra.ecr_launcher_repository_url
  launcher_image_tag = local.spacelift_version

  admin_username = "admin"      # Temporary for the initial setup, will be removed
  admin_password = "1P@ssw0rd"  # Temporary for the initial setup, will be removed

  vpc_id      = module.spacelift_infra.vpc_id
  ecs_subnets = module.spacelift_infra.private_subnet_ids

  server_lb_subnets           = module.spacelift_infra.public_subnet_ids
  server_security_group_id    = module.spacelift_infra.server_security_group_id
  server_lb_certificate_arn   = "<LB certificate ARN>" # Note that this certificate MUST be successfully issued. It cannot be attached to the load balancer in a pending state.

  drain_security_group_id     = module.spacelift_infra.drain_security_group_id
  scheduler_security_group_id = module.spacelift_infra.scheduler_security_group_id

  mqtt_lb_subnets = module.spacelift_infra.public_subnet_ids

  deliveries_bucket_name               = module.spacelift_infra.deliveries_bucket_name
  large_queue_messages_bucket_name     = module.spacelift_infra.large_queue_messages_bucket_name
  metadata_bucket_name                 = module.spacelift_infra.metadata_bucket_name
  modules_bucket_name                  = module.spacelift_infra.modules_bucket_name
  policy_inputs_bucket_name            = module.spacelift_infra.policy_inputs_bucket_name
  run_logs_bucket_name                 = module.spacelift_infra.run_logs_bucket_name
  states_bucket_name                   = module.spacelift_infra.states_bucket_name
  uploads_bucket_name                  = module.spacelift_infra.uploads_bucket_name
  uploads_bucket_url                   = module.spacelift_infra.uploads_bucket_url
  user_uploaded_workspaces_bucket_name = module.spacelift_infra.user_uploaded_workspaces_bucket_name
  workspace_bucket_name                = module.spacelift_infra.workspace_bucket_name
}
```

This module creates:

- Load balancers
  - An ALB for the Spacelift server (needs a valid ACM certificate)
  - A network load balancer for the MQTT broker (when using the default `builtin` broker type)
  - A security group for the load balancers
- ECS
  - An ECS cluster
  - Three services (server, drain, scheduler)
  - IAM roles and policies for the corresponding services

Once it succeeded, don't forget to create a DNS record (`CNAME`) for the server and MQTT load balancer (if using the `builtin` broker type).

### With CloudWatch logging

You can pass in a log configuration for each service. See [the official documentation](https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_LogConfiguration.html) for the configuration schema.

```hcl
module "spacelift_services" {
  source = "github.com/spacelift-io/terraform-aws-ecs-spacelift-selfhosted?ref=v1.1.0"

  server_log_configuration = {
    logDriver : "awslogs",
    options : {
      "awslogs-region" : var.region,
      "awslogs-group" : "/ecs/spacelift-server",
      "awslogs-create-group" : "true",
      "awslogs-stream-prefix" : "server"
      "mode": "non-blocking"
      "max-buffer-size": 25m
    }
  }

  drain_log_configuration = {
    logDriver : "awslogs",
    options : {
      "awslogs-region" : var.region,
      "awslogs-group" : "/ecs/spacelift-drain",
      "awslogs-create-group" : "true",
      "awslogs-stream-prefix" : "drain"
      "mode": "non-blocking"
      "max-buffer-size": 25m
    }
  }

  scheduler_log_configuration = {
    logDriver : "awslogs",
    options : {
      "awslogs-region" : var.region,
      "awslogs-group" : "/ecs/spacelift-scheduler",
      "awslogs-create-group" : "true",
      "awslogs-stream-prefix" : "scheduler"
      "mode": "non-blocking"
      "max-buffer-size": 25m
    }
  }

  # Further configuration removed for brevity
}
```

### Deploy with existing IAM roles

```hcl
module "spacelift_services" {
  source = "github.com/spacelift-io/terraform-aws-ecs-spacelift-selfhosted?ref=v1.1.0"

  execution_role_arn = aws_iam_role.execution_role.arn
  server_role_arn    = aws_iam_role.spacelift_server_role.arn
  drain_role_arn     = aws_iam_role.spacelift_drain_role.arn
  scheduler_role_arn = aws_iam_role.spacelift_scheduler_role.arn

  # Further configuration removed for brevity
}

resource "aws_iam_role" "execution_role" {
  name = "spacelift-execution-role"
  # Further configuration removed for brevity
}

resource "aws_iam_role" "spacelift_server_role" {
  name = "spacelift-server-role"
  # Further configuration removed for brevity
}

resource "aws_iam_role" "spacelift_drain_role" {
  name = "spacelift-drain-role"
  # Further configuration removed for brevity
}

resource "aws_iam_role" "spacelift_scheduler_role" {
  name = "spacelift-scheduler-role"
  # Further configuration removed for brevity
}
```

## Module registries

The module is also available [on the OpenTofu registry](https://search.opentofu.org/module/spacelift-io/ecs-spacelift-selfhosted/aws/latest) where you can browse the input and output variables.

## Additional Configuration Options

### Message Broker Types

This module supports two types of MQTT brokers:

1. **Built-in MQTT broker (mqtt_broker_type = "builtin")**
   - When using the built-in broker, the Spacelift server acts as the MQTT broker, but listens on a different port.
     - A separate Network Load Balancer (NLB) is created for the MQTT broker port.
     - The NLB doesn't require an ACM certificate. TLS is handled inside the Spacelift MQTT broker.  
   - Requires DNS configuration (`CNAME`) for the MQTT broker endpoint.
   - Set in your configuration with: `mqtt_broker_type = "builtin"` (this is the default), and `mqtt_broker_endpoint = "tls://<endpoint address>"`.

2. **AWS IoT Core (mqtt_broker_type = "iotcore")**
   - Uses AWS IoT Core as the MQTT broker
   - No separate load balancer is created
   - Set in your configuration with: `mqtt_broker_type = "iotcore"`
   - **Important**: when the `mqtt_broker_type` is set to `iotcore`, the message queue type must be SQS, hence the `sqs_queues` variable is a must. This is because the AWS IoT Core broker publishes message to SQS queues.

### Message Queue Types

The Spacelift server supports two types of message queues:

1. **Default PostgreSQL (MESSAGE_QUEUE_TYPE = "postgres")**
   - Uses the same PostgreSQL database for message queuing
   - No additional configuration required

2. **AWS SQS (MESSAGE_QUEUE_TYPE = "sqs")**
   - Uses AWS SQS for message queuing
   - Requires the `sqs_queues` variable with queue names
   - If you set the `mqtt_broker_type` to `iotcore`, the message queue type must be SQS, hence the `sqs_queues` variable is a must.
   - Automatically fetches ARNs and URLs using data sources
   - Configure in your module with:
   ```hcl
   sqs_queues = {
     deadletter      = "<your-deadletter-queue-name>"
     deadletter_fifo = "<your-deadletter-fifo-queue-name>"
     async_jobs      = "<your-async-jobs-queue-name>"
     events_inbox    = "<your-events-inbox-queue-name>"
     async_jobs_fifo = "<your-async-jobs-fifo-queue-name>"
     cronjobs        = "<your-cronjobs-queue-name>"
     webhooks        = "<your-webhooks-queue-name>"
     iot             = "<your-iot-queue-name>"
   }
   ```

## 🚀 Release

We have a [GitHub workflow](./.github/workflows/release.yaml) to automatically create a tag and a release based on the version number in [`.spacelift/config.yml`](./.spacelift/config.yml) file.

When you're ready to release a new version, just simply bump the version number in the config file and open a pull request. Once the pull request is merged, the workflow will create a new release.