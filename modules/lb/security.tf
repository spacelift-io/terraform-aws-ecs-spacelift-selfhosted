resource "aws_security_group" "load_balancer_sg" {
  name        = "load-balancer-sg"
  description = "Allow HTTP and HTTPS traffic to the load balancer"
  vpc_id      = var.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "server_ingress_rule" {
  security_group_id = aws_security_group.load_balancer_sg.id

  description                  = "Accept HTTP connections on port ${var.server_port} from the server load balancer"
  from_port                    = var.server_port
  to_port                      = var.server_port
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.load_balancer_sg.id
}

resource "aws_vpc_security_group_ingress_rule" "mqtt_server_ingress_rule" {
  security_group_id = aws_security_group.load_balancer_sg.id

  description                  = "Accept HTTP connections on port ${var.mqtt_port} from the MQTT load balancer"
  from_port                    = var.mqtt_port
  to_port                      = var.mqtt_port
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.load_balancer_sg.id
}
