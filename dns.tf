resource "aws_route53_record" "alias" {
  for_each = var.create_dns_records && var.route53_zone_id != null ? toset(var.hostnames) : toset([])

  zone_id = var.route53_zone_id
  name    = each.value
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = false
  }

  allow_overwrite = true
}
