resource "aws_security_group" "load_balancer_sg" {
  count = var.load_balancer_security_group_id == null ? 1 : 0

  name        = "load_balancer_sg_${var.suffix}"
  description = "Allow HTTP and HTTPS traffic to the load balancer"
  vpc_id      = var.vpc_id
}

resource "aws_vpc_security_group_egress_rule" "lb_http_towards_server" {
  count             = var.load_balancer_security_group_id == null ? 1 : 0
  security_group_id = local.load_balancer_security_group_id

  description                  = "Allow all traffic to the server"
  from_port                    = var.server_port
  to_port                      = var.server_port
  ip_protocol                  = "tcp"
  referenced_security_group_id = var.server_security_group_id
}

resource "aws_vpc_security_group_egress_rule" "lb_mqtt_towards_server" {
  count = var.mqtt_broker_type == "builtin" ? 1 : 0

  security_group_id = local.load_balancer_security_group_id

  description                  = "Allow all traffic to the server"
  from_port                    = var.mqtt_port
  to_port                      = var.mqtt_port
  ip_protocol                  = "tcp"
  referenced_security_group_id = var.server_security_group_id
}

resource "aws_vpc_security_group_ingress_rule" "tls" {
  count             = var.load_balancer_security_group_id == null ? 1 : 0
  security_group_id = local.load_balancer_security_group_id

  description = "Accept HTTP connections on port 443"
  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"
  cidr_ipv4   = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "mqtt" {
  count = var.mqtt_broker_type == "builtin" ? 1 : 0

  security_group_id = local.load_balancer_security_group_id

  description = "Accept TLS connections on port 1984 for built in MQTT server"
  from_port   = var.mqtt_port
  to_port     = var.mqtt_port
  ip_protocol = "tcp"
  cidr_ipv4   = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "http_lb_to_server" {
  count             = var.load_balancer_security_group_id == null ? 1 : 0
  security_group_id = var.server_security_group_id

  description                  = "Allow http connections from the load balancer"
  from_port                    = var.server_port
  to_port                      = var.server_port
  ip_protocol                  = "tcp"
  referenced_security_group_id = local.load_balancer_security_group_id
}

resource "aws_vpc_security_group_ingress_rule" "mqtt_lb_to_server" {
  count = var.mqtt_broker_type == "builtin" ? 1 : 0

  security_group_id = var.server_security_group_id

  description                  = "Allow MQTT connections from the load balancer"
  from_port                    = var.mqtt_port
  to_port                      = var.mqtt_port
  ip_protocol                  = "tcp"
  referenced_security_group_id = local.load_balancer_security_group_id
}

resource "aws_security_group" "vcs_gateway_lb_sg" {
  count = var.vcs_gateway_service_security_group_id != null ? 1 : 0

  name        = "vcs-gateway-loadbalancer-sg-${var.suffix}"
  description = "Allow HTTPS traffic to the VCS gateway"
  vpc_id      = var.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "vcs_gateway_https" {
  count = var.vcs_gateway_service_security_group_id != null ? 1 : 0

  security_group_id = aws_security_group.vcs_gateway_lb_sg[0].id

  description = "Allow HTTPS traffic to the VCS gateway"
  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"
  cidr_ipv4   = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "vcs_gateway_lb_to_gateway_service" {
  count = var.vcs_gateway_service_security_group_id != null ? 1 : 0

  security_group_id = aws_security_group.vcs_gateway_lb_sg[0].id

  description                  = "Allow traffic to the VCS gateway service"
  from_port                    = var.vcs_gateway_external_port
  to_port                      = var.vcs_gateway_external_port
  ip_protocol                  = "tcp"
  referenced_security_group_id = var.vcs_gateway_service_security_group_id
}

resource "aws_vpc_security_group_ingress_rule" "vcs_gateway_service_grpc_from_lb" {
  count = var.vcs_gateway_service_security_group_id != null ? 1 : 0

  security_group_id = var.vcs_gateway_service_security_group_id

  description                  = "(gRPC) Allow the load balancer to connect to the VCS gateway - this is used by remote agents connecting to the gateway"
  from_port                    = var.vcs_gateway_external_port
  to_port                      = var.vcs_gateway_external_port
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.vcs_gateway_lb_sg[0].id
}

resource "aws_vpc_security_group_ingress_rule" "vcs_gateway_service_allow_from_server" {
  count = var.vcs_gateway_service_security_group_id != null ? 1 : 0

  security_group_id = var.vcs_gateway_service_security_group_id

  description                  = "(HTTP) Allow the server to connect to the VCS gateway"
  from_port                    = var.vcs_gateway_internal_port
  to_port                      = var.vcs_gateway_internal_port
  ip_protocol                  = "tcp"
  referenced_security_group_id = var.server_security_group_id
}

resource "aws_vpc_security_group_ingress_rule" "vcs_gateway_service_allow_from_drain" {
  count = var.vcs_gateway_service_security_group_id != null ? 1 : 0

  security_group_id = var.vcs_gateway_service_security_group_id

  description                  = "(HTTP) Allow the drain to connect to the VCS gateway"
  from_port                    = var.vcs_gateway_internal_port
  to_port                      = var.vcs_gateway_internal_port
  ip_protocol                  = "tcp"
  referenced_security_group_id = var.drain_security_group_id
}
