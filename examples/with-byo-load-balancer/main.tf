# Bring-your-own load balancer for the Spacelift server.
#
# Instead of letting the module provision the server ALB, we stand up our own
# load balancer, target group and listener here and register the server
# service into it via `byo_server_target_group_arns`. Once that variable is
# set, the module skips its own server ALB and the related security group rules.
#
# When you bring your own load balancer you also own the plumbing around it:
# the LB security group, the ingress rule on the server security group that
# lets the LB reach the service, and the health check configuration.

resource "aws_security_group" "server_lb" {
  name        = "byo-server-lb-${var.unique_suffix}"
  description = "BYO load balancer for the Spacelift server"
  vpc_id      = var.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "server_lb_https" {
  security_group_id = aws_security_group.server_lb.id

  description = "Accept HTTPS connections"
  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"
  cidr_ipv4   = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "server_lb_to_server" {
  security_group_id = aws_security_group.server_lb.id

  description                  = "Forward traffic to the server service"
  from_port                    = 1983
  to_port                      = 1983
  ip_protocol                  = "tcp"
  referenced_security_group_id = var.server_security_group_id
}

# The module no longer manages this rule when it doesn't own the load balancer,
# so we add it ourselves to let the BYO LB reach the server service.
resource "aws_vpc_security_group_ingress_rule" "server_from_lb" {
  security_group_id = var.server_security_group_id

  description                  = "Allow the BYO load balancer to reach the server"
  from_port                    = 1983
  to_port                      = 1983
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.server_lb.id
}

resource "aws_lb" "server" {
  name               = "byo-server-lb-${var.unique_suffix}"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.server_lb.id]
  subnets            = var.public_subnet_ids
  internal           = false
}

resource "aws_lb_target_group" "server" {
  name = "byo-server-tg-${var.unique_suffix}"

  port        = 1983
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    path                = "/health"
    matcher             = "200"
    interval            = 10
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "server" {
  load_balancer_arn = aws_lb.server.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = var.lb_certificate_arn
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.server.arn
  }
}

module "this" {
  source = "../../"

  region               = var.region
  unique_suffix        = var.unique_suffix
  kms_key_arn          = var.kms_key_arn
  server_domain        = var.website_domain
  mqtt_broker_endpoint = var.mqtt_broker_endpoint

  license_token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJkaWQgeW91IHJlYWxseSB0aGluayB3ZSdsbCBhZGQgYSB2YWxpZCB0b2tlbiBoZXJlPyA6KSJ9.I60CMAP8z_ULiJgKMRrJqHgmYaiRm8PjSJh_l3AoCrU"

  encryption_type        = "kms"
  kms_encryption_key_arn = var.kms_encryption_key_arn
  kms_signing_key_arn    = var.kms_signing_key_arn

  # The secret ARNs don't need to be valid since the service desired count is 0
  sensitive_env_vars = [
    {
      name      = "DATABASE_URL",
      valueFrom = "arn:aws:secretsmanager:${var.region}:000000000000:secret:spacelift/database-abc123:DATABASE_URL::"
    },
    {
      name      = "DATABASE_READ_ONLY_URL",
      valueFrom = "arn:aws:secretsmanager:${var.region}:000000000000:secret:spacelift/database-abc123:DATABASE_READ_ONLY_URL::"
    }
  ]
  secrets_manager_secret_arns = ["arn:aws:secretsmanager:${var.region}:000000000000:secret:spacelift/database-abc123"]

  backend_image      = var.ecr_backend_repository_url
  backend_image_tag  = var.spacelift_version
  launcher_image     = var.ecr_launcher_repository_url
  launcher_image_tag = var.spacelift_version

  vpc_id      = var.vpc_id
  ecs_subnets = var.private_subnet_ids

  byo_server_target_group_arns = [aws_lb_target_group.server.arn]

  server_security_group_id        = var.server_security_group_id
  load_balancer_security_group_id = var.load_balancer_security_group_id
  server_desired_count            = 0

  drain_security_group_id = var.drain_security_group_id
  drain_desired_count     = 0

  scheduler_security_group_id = var.scheduler_security_group_id
  scheduler_desired_count     = 0

  mqtt_lb_subnets = var.public_subnet_ids

  # The bucket names doesn't need to be valid since the service desired count is 0
  deliveries_bucket_name               = "deliveries"
  large_queue_messages_bucket_name     = "large-queue-messages"
  metadata_bucket_name                 = "metadata"
  modules_bucket_name                  = "modules"
  policy_inputs_bucket_name            = "policy-inputs"
  run_logs_bucket_name                 = "run-logs"
  states_bucket_name                   = "states"
  uploads_bucket_name                  = "uploads"
  uploads_bucket_url                   = "uploads"
  user_uploaded_workspaces_bucket_name = "user-uploaded-workspaces"
  workspace_bucket_name                = "workspace"
}
