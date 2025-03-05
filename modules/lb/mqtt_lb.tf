resource "aws_lb" "mqtt" {
  name               = "spacelift-mqtt-${var.suffix}"
  security_groups    = [aws_security_group.load_balancer_sg.id]
  subnets            = var.mqtt_lb_subnets
  load_balancer_type = "network"
  internal           = var.mqtt_lb_internal
}

resource "aws_lb_target_group" "mqtt" {
  name        = "spacelift-mqtt-tg-${var.suffix}"
  port        = var.mqtt_port
  protocol    = "TCP"
  target_type = "ip"
  vpc_id      = var.vpc_id
}

resource "aws_lb_listener" "mqtt" {
  load_balancer_arn = aws_lb.mqtt.arn
  port              = var.mqtt_port
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.mqtt.arn
  }
}
