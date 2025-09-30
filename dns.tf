resource "aws_route53_record" "alias" {
  for_each = var.create_dns_records && local.effective_route53_zone_id != null ? toset(var.hostnames) : toset([])

  zone_id = local.effective_route53_zone_id
  name    = each.value
  type    = "A"

  alias {
    name    = local.effective_alb_dns_name
    zone_id = local.effective_alb_zone_id
    evaluate_target_health = false
  }

  allow_overwrite = true
}
