resource "aws_lb" "vcs_gateway" {
  count = var.vcs_gateway_service_security_group_id != null ? 1 : 0

  name               = "vcs-gateway-lb-${var.suffix}"
  load_balancer_type = "application"
  idle_timeout       = 3600
  security_groups    = [aws_security_group.vcs_gateway_lb_sg[0].id]
  subnets            = var.vcs_gateway_lb_subnets
  internal           = var.vcs_gateway_internal
}

resource "aws_lb_target_group" "vcs_gateway" {
  count = var.vcs_gateway_service_security_group_id != null ? 1 : 0

  name = "vcs-gateway-tf-${var.suffix}"

  port                 = var.vcs_gateway_external_port
  protocol             = "HTTP"
  protocol_version     = "GRPC"
  target_type          = "ip"
  deregistration_delay = 60
  vpc_id               = var.vpc_id

  health_check {
    enabled             = true
    path                = "/AWS.ALB/healthcheck"
    matcher             = "12"
    interval            = 30
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "vcs_gateway" {
  count = var.vcs_gateway_service_security_group_id != null ? 1 : 0

  load_balancer_arn = aws_lb.vcs_gateway[0].arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = var.vcs_gateway_certificate_arn
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"

  default_action {
    target_group_arn = aws_lb_target_group.vcs_gateway[0].arn
    type             = "forward"
  }
}
