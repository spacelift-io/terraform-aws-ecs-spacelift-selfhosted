resource "aws_lb" "server" {
  count = var.create_server_lb ? 1 : 0

  name               = coalesce(var.server_lb_name, "server-lb-${var.suffix}")
  load_balancer_type = "application"
  security_groups    = [local.load_balancer_security_group_id]
  subnets            = var.server_lb_subnets
  internal           = var.server_lb_internal
}

resource "aws_lb_target_group" "server" {
  count = var.create_server_lb ? 1 : 0

  name = "spacelift-server-tf-${var.suffix}"

  deregistration_delay = 90
  slow_start           = 45
  port                 = var.server_port
  protocol             = "HTTP"
  target_type          = "ip"
  vpc_id               = var.vpc_id

  health_check {
    interval            = 10
    matcher             = "200"
    path                = "/health"
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "server" {
  count = var.create_server_lb ? 1 : 0

  load_balancer_arn = aws_lb.server[0].arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = var.server_lb_certificate_arn
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"

  default_action {
    target_group_arn = aws_lb_target_group.server[0].arn
    type             = "forward"
  }
}
