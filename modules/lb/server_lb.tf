resource "aws_lb" "server" {
  name               = "server-lb-${var.suffix}"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.load_balancer_sg.id]
  subnets            = var.server_lb_subnets
  internal           = var.server_lb_internal
}

resource "aws_lb_target_group" "server" {
  name = "spacelift-tg-${var.suffix}"

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
  load_balancer_arn = aws_lb.server.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = var.server_lb_certificate_arn
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"

  default_action {
    target_group_arn = aws_lb_target_group.server.arn
    type             = "forward"
  }
}
