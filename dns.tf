# Per-service Route53 A/ALIAS records for hostnames → ALB
resource "aws_route53_record" "host_alias" {
  for_each = var.expose_via_alb && var.create_dns_records ? toset(var.hostnames) : []

  zone_id = var.route53_zone_id
  name    = each.value
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = false
  }

  lifecycle {
    precondition {
      condition     = var.route53_zone_id != null && var.alb_dns_name != null && var.alb_zone_id != null
      error_message = "To create DNS records set route53_zone_id, alb_dns_name, alb_zone_id."
    }
  }
}
