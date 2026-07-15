locals {
  spacelift_public_api = "https://app.spacelift.io"

  drain_sidecar_dependencies = concat(
    var.enable_datadog_agent_sidecar && var.datadog_agent_config != null ? [{
      containerName = "datadog-agent"
      condition     = "START"
    }] : [],
    var.enable_otel_sidecar && var.otel_config != null ? [{
      containerName = "aws-otel-collector"
      condition     = "START"
    }] : []
  )

  default_drain_container_definition = jsonencode(concat(
    [
      merge(
        {
          name      = "drain"
          command   = ["spacelift", "backend", "drain"]
          essential = true
          image     = var.backend_image
          ulimits = [
            {
              name      = "nofile"
              softLimit = 65536
              hardLimit = 65536
            }
          ]
          logConfiguration = var.drain_log_configuration
          environment = concat(
            var.shared_envs,
            [
              {
                name  = "LAUNCHER_IMAGE"
                value = var.launcher_image
              },
              {
                name  = "LAUNCHER_IMAGE_TAG"
                value = var.launcher_image_tag
              },
              {
                name  = "SPACELIFT_PUBLIC_API"
                value = var.enable_automatic_usage_data_reporting ? local.spacelift_public_api : ""
              },
              {
                name  = "DRAIN_CONCURRENCY_ASYNC_JOBS"
                value = tostring(var.drain_concurrency_async_jobs)
              },
              {
                name  = "DRAIN_CONCURRENCY_ASYNC_JOBS_FIFO"
                value = tostring(var.drain_concurrency_async_jobs_fifo)
              },
              {
                name  = "DRAIN_CONCURRENCY_CRONJOBS"
                value = tostring(var.drain_concurrency_cronjobs)
              },
              {
                name  = "DRAIN_CONCURRENCY_DLQ"
                value = tostring(var.drain_concurrency_dlq)
              },
              {
                name  = "DRAIN_CONCURRENCY_DLQ_FIFO"
                value = tostring(var.drain_concurrency_dlq_fifo)
              },
              {
                name  = "DRAIN_CONCURRENCY_EVENTS"
                value = tostring(var.drain_concurrency_events)
              },
              {
                name  = "DRAIN_CONCURRENCY_IOT"
                value = tostring(var.drain_concurrency_iot)
              },
              {
                name  = "DRAIN_CONCURRENCY_WEBHOOKS"
                value = tostring(var.drain_concurrency_webhooks)
              }
            ],
            var.sqs_queues != null ? [
              {
                name  = "MESSAGE_QUEUE_SQS_DLQ_URL"
                value = var.sqs_queues.deadletter_url
              },
              {
                name  = "MESSAGE_QUEUE_SQS_DLQ_FIFO_URL"
                value = var.sqs_queues.deadletter_fifo_url
              },
              {
                name  = "MESSAGE_QUEUE_SQS_IOT_URL"
                value = var.sqs_queues.iot_url
              }
            ] : []
          )
          secrets = concat(
            [
              {
                name      = "LICENSE_TOKEN",
                valueFrom = "${var.shared_secrets_arn}:LICENSE_TOKEN::"
              }
            ],
            var.sensitive_env_vars
          )
        },
        length(local.drain_sidecar_dependencies) > 0 ? {
          dependsOn = local.drain_sidecar_dependencies
        } : {}
      )
    ],
    local.datadog_agent_container,
    local.otel_container
  ))
}
