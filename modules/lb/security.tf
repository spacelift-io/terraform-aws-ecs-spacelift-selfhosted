resource "aws_security_group" "load_balancer_sg" {
  name        = "load-balancer-sg"
  description = "Allow HTTP and HTTPS traffic to the load balancer"
  vpc_id      = var.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "tls" {
  security_group_id = aws_security_group.load_balancer_sg.id

  description = "Accept HTTP connections on port 443"
  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"
  cidr_ipv4   = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "mqtt" {
  security_group_id = aws_security_group.load_balancer_sg.id

  description = "Accept TLS connections on port 1984 for built in MQTT server"
  from_port   = 1984
  to_port     = 1984
  ip_protocol = "tcp"
  cidr_ipv4   = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "http_lb_to_server" {
  security_group_id = var.server_security_group_id

  description                  = "Allow http connections from the load balancer"
  from_port                    = 1983
  to_port                      = 1983
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.load_balancer_sg.id
}

resource "aws_vpc_security_group_ingress_rule" "mqtt_lb_to_server" {
  security_group_id = var.server_security_group_id

  description                  = "Allow MQTT connections from the load balancer"
  from_port                    = 1984
  to_port                      = 1984
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.load_balancer_sg.id
}
