locals {
  load_balancer_security_group_id = var.load_balancer_security_group_id != null ? var.load_balancer_security_group_id : aws_security_group.load_balancer_sg[0].id
}
