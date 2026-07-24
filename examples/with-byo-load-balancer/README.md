# Bring your own load balancer

By default the module provisions an Application Load Balancer for the Spacelift server, along with its target group, listener and security group. If you already run your own load balancer (custom routing, WAF rules, a shared ALB, etc.), you can register the server service into your own target group instead and skip the module-managed one.

Set `byo_server_target_group_arns` to one or more target group ARNs. Once it's set, the module stops creating the server ALB, its target group, listener and the server-specific security group rules. `server_lb_subnets` and `server_lb_certificate_arn` are no longer required in this mode.

```hcl
module "spacelift" {
  source = "github.com/spacelift-io/terraform-aws-ecs-spacelift-selfhosted"

  # ... other required variables ...

  byo_server_target_group_arns = [aws_lb_target_group.my_server.arn]
}
```

## What you own

When you bring your own load balancer, the module no longer manages the wiring between the LB and the server service. You're responsible for:

- The load balancer, its listener and TLS certificate.
- A target group with `target_type = "ip"` on the server port (`1983`) and a health check against `/health`.
- A security group rule allowing your load balancer to reach the server service security group on the server port.

The [`main.tf`](./main.tf) in this directory shows a complete setup: a self-managed ALB, target group, listener and the security group rules, all wired into the module through `byo_server_target_group_arns`.

> [!NOTE]
> This only affects the server load balancer. The MQTT broker load balancer (when using the `builtin` broker type) is unaffected.
