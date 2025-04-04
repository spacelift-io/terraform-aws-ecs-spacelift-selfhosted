resource "aws_ecs_cluster" "cluster" {
  name = "spacelift-${var.suffix}"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_cluster_capacity_providers" "cluster" {
  cluster_name = aws_ecs_cluster.cluster.name

  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}

resource "aws_ecs_service" "server" {
  name    = "server"
  cluster = aws_ecs_cluster.cluster.id

  desired_count   = var.server_desired_count
  task_definition = aws_ecs_task_definition.server.arn

  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200
  availability_zone_rebalancing      = var.ecs_service_az_rebalancing_enabled
  wait_for_steady_state              = true

  capacity_provider_strategy {
    base              = 1
    capacity_provider = "FARGATE"
    weight            = 100
  }

  network_configuration {
    assign_public_ip = false
    security_groups  = [var.server_security_group]
    subnets          = var.subnets
  }

  load_balancer {
    target_group_arn = var.server_target_group_arn
    container_name   = "server"
    container_port   = var.server_port
  }

  load_balancer {
    target_group_arn = var.mqtt_server_target_group_arn
    container_name   = "server"
    container_port   = var.mqtt_broker_port
  }
}

resource "aws_ecs_service" "drain" {
  name    = "drain"
  cluster = aws_ecs_cluster.cluster.id

  desired_count   = var.drain_desired_count
  task_definition = aws_ecs_task_definition.drain.arn

  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200
  availability_zone_rebalancing      = var.ecs_service_az_rebalancing_enabled
  wait_for_steady_state              = true

  capacity_provider_strategy {
    base              = 1
    capacity_provider = "FARGATE"
    weight            = 100
  }

  network_configuration {
    assign_public_ip = false
    security_groups  = [var.drain_security_group]
    subnets          = var.subnets
  }
}

resource "aws_ecs_service" "scheduler" {
  name    = "scheduler"
  cluster = aws_ecs_cluster.cluster.id

  desired_count   = var.scheduler_desired_count
  task_definition = aws_ecs_task_definition.scheduler.arn

  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200
  availability_zone_rebalancing      = var.ecs_service_az_rebalancing_enabled
  wait_for_steady_state              = true

  capacity_provider_strategy {
    base              = 1
    capacity_provider = "FARGATE"
    weight            = 100
  }

  network_configuration {
    assign_public_ip = false
    security_groups  = [var.scheduler_security_group]
    subnets          = var.subnets
  }
}
