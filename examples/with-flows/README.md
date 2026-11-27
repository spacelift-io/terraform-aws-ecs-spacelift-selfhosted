# With Flows Example

This example deploys Spacelift Self-Hosted on ECS together with [Spacelift Flows](https://docs.spacelift.io/flows/introduction).

Flows runs in the same ECS cluster as Spacelift and uses the same database cluster. The bucket, its KMS key and the database URL come from the [terraform-aws-spacelift-selfhosted](https://github.com/spacelift-io/terraform-aws-spacelift-selfhosted) module, with `enable_flows = true` set on it. This module adds the Flows server, worker and gateway services, an IAM role and a load balancer for them.

## Prerequisites

- A license that includes Flows.
- An ACM certificate for the Flows domain. It must be **separate from the server certificate**, successfully issued, and cover:
  - `flows.spacelift.io`
  - `*.endpoints.flows.spacelift.io`
  - `oauth.flows.spacelift.io`
  - `mcp.flows.spacelift.io`
  - `gateway.flows.spacelift.io`

## Usage

See [main.tf](main.tf). It only shows the Flows-specific part, so it doesn't apply on its own: add the `flows` block to your existing configuration of the module. In `flows`, `domain`, `certificate_arn`, `organization_name`, `admin_email`, `admin_password`, `database_url`, `bucket_name`, `kms_key_arn` and `lb_subnets` are required, the rest is optional.

## Next Steps

After applying, create DNS records (`CNAME`) for the names above that point to the `flows_lb_dns_name` output.

The Flows agents are not deployed by this module. To configure them, use the `flows_agent_pool_id` and `flows_agent_pool_token` outputs.
