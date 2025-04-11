data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

data "aws_iot_endpoint" "iot" {
  count         = var.mqtt_broker_type == "iotcore" ? 1 : 0
  endpoint_type = "iot:Data-ATS"
}

data "aws_sqs_queue" "deadletter" {
  count = var.sqs_queues != null ? 1 : 0
  name  = var.sqs_queues.deadletter
}

data "aws_sqs_queue" "deadletter_fifo" {
  count = var.sqs_queues != null ? 1 : 0
  name  = var.sqs_queues.deadletter_fifo
}

data "aws_sqs_queue" "async_jobs" {
  count = var.sqs_queues != null ? 1 : 0
  name  = var.sqs_queues.async_jobs
}

data "aws_sqs_queue" "events_inbox" {
  count = var.sqs_queues != null ? 1 : 0
  name  = var.sqs_queues.events_inbox
}

data "aws_sqs_queue" "async_jobs_fifo" {
  count = var.sqs_queues != null ? 1 : 0
  name  = var.sqs_queues.async_jobs_fifo
}

data "aws_sqs_queue" "cronjobs" {
  count = var.sqs_queues != null ? 1 : 0
  name  = var.sqs_queues.cronjobs
}

data "aws_sqs_queue" "webhooks" {
  count = var.sqs_queues != null ? 1 : 0
  name  = var.sqs_queues.webhooks
}

data "aws_sqs_queue" "iot" {
  count = var.sqs_queues != null ? 1 : 0
  name  = var.sqs_queues.iot
}
