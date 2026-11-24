resource "aws_lb" "flows" {
  count = var.flows != null ? 1 : 0

  name                 = "flows-lb-${var.suffix}"
  region               = var.region
  load_balancer_type   = "application"
  idle_timeout         = 3600
  preserve_host_header = true
  security_groups      = [aws_security_group.flows_lb_sg[0].id]
  subnets              = var.flows.lb_subnets
  internal             = var.flows.lb_internal
}

resource "aws_lb_target_group" "flows_server" {
  count = var.flows != null ? 1 : 0

  name   = "flows-server-tf-${var.suffix}"
  region = var.region

  deregistration_delay = 60
  port                 = var.flows.port
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

resource "aws_lb_target_group" "flows_gateway" {
  count = var.flows != null ? 1 : 0

  name   = "flows-gateway-tf-${var.suffix}"
  region = var.region

  deregistration_delay = 60
  port                 = var.flows.port
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

resource "aws_lb_listener" "flows" {
  count = var.flows != null ? 1 : 0

  region            = var.region
  load_balancer_arn = aws_lb.flows[0].arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = var.flows.certificate_arn
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"

  default_action {
    target_group_arn = aws_lb_target_group.flows_server[0].arn
    type             = "forward"
  }
}

resource "aws_lb_listener_rule" "flows_gateway" {
  count = var.flows != null ? 1 : 0

  region       = var.region
  listener_arn = aws_lb_listener.flows[0].arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.flows_gateway[0].arn
  }

  condition {
    host_header {
      values = ["gateway.${var.flows.domain}"]
    }
  }
}

resource "aws_security_group" "flows_lb_sg" {
  count = var.flows != null ? 1 : 0

  name        = "flows-loadbalancer-sg-${var.suffix}"
  region      = var.region
  description = "Allow HTTPS traffic to Spacelift Flows"
  vpc_id      = var.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "flows_https" {
  count = var.flows != null ? 1 : 0

  security_group_id = aws_security_group.flows_lb_sg[0].id
  region            = var.region

  description = "Allow HTTPS traffic to Spacelift Flows"
  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"
  cidr_ipv4   = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "flows_lb_to_flows_services" {
  count = var.flows != null ? 1 : 0

  security_group_id = aws_security_group.flows_lb_sg[0].id
  region            = var.region

  description                  = "Allow traffic to the Flows server and gateway"
  from_port                    = var.flows.port
  to_port                      = var.flows.port
  ip_protocol                  = "tcp"
  referenced_security_group_id = var.flows.security_group_id
}

resource "aws_vpc_security_group_ingress_rule" "flows_services_from_lb" {
  count = var.flows != null ? 1 : 0

  security_group_id = var.flows.security_group_id
  region            = var.region

  description                  = "Allow the load balancer to connect to the Flows server and gateway"
  from_port                    = var.flows.port
  to_port                      = var.flows.port
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.flows_lb_sg[0].id
}

resource "aws_vpc_security_group_ingress_rule" "flows_gateway_internal" {
  count = var.flows != null ? 1 : 0

  security_group_id = var.flows.security_group_id
  region            = var.region

  description                  = "Allow the Flows server and worker to connect to the internal port of the Flows gateway"
  from_port                    = var.flows.gateway_internal_port
  to_port                      = var.flows.gateway_internal_port
  ip_protocol                  = "tcp"
  referenced_security_group_id = var.flows.security_group_id
}
