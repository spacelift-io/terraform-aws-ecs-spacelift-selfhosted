resource "aws_lb" "mqtt" {
  count              = var.mqtt_broker_type == "builtin" ? 1 : 0
  name               = "spacelift-mqtt-${var.suffix}"
  security_groups    = [local.load_balancer_security_group_id]
  subnets            = var.mqtt_lb_subnets
  load_balancer_type = "network"
  internal           = var.mqtt_lb_internal
}

resource "aws_lb_target_group" "mqtt" {
  count       = var.mqtt_broker_type == "builtin" ? 1 : 0
  name        = "spacelift-mqtt-tg-${var.suffix}"
  port        = var.mqtt_port
  protocol    = "TCP"
  target_type = "ip"
  vpc_id      = var.vpc_id
}

resource "aws_lb_listener" "mqtt" {
  count             = var.mqtt_broker_type == "builtin" ? 1 : 0
  load_balancer_arn = aws_lb.mqtt[0].arn
  port              = var.mqtt_port
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.mqtt[0].arn
  }
}
