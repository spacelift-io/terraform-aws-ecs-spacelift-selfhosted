# The server LB resources gained count when the server load balancer became
# optional, changing their addresses to [0]. These moved blocks keep existing
# deployments from destroying and recreating their ALB on upgrade.
moved {
  from = aws_lb.server
  to   = aws_lb.server[0]
}

moved {
  from = aws_lb_target_group.server
  to   = aws_lb_target_group.server[0]
}

moved {
  from = aws_lb_listener.server
  to   = aws_lb_listener.server[0]
}
