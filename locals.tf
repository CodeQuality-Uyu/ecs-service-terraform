locals {
  # pull from remote_state if present; else use explicit variables
  effective_vpc_id = coalesce(
    var.vpc_id,
    try(data.terraform_remote_state.network[0].outputs.vpc_id, null)
  )

  effective_subnet_ids = var.subnet_ids != null ? var.subnet_ids : try(data.terraform_remote_state.network[0].outputs.private_subnet_ids, null)

  effective_cluster_arn = coalesce(
    var.cluster_arn,
    try(data.terraform_remote_state.cluster[0].outputs.ecs_cluster_arn, null)
  )

  # prefer "ingress" if present, else "alb"
  ingress_outputs = try(data.terraform_remote_state.alb[0].outputs, null)

  # Collect possible keys for the :443 listener ARN
  https_listener_candidates = compact([
    var.https_listener_arn,
    try(local.ingress_outputs.https_443_listener_arn,  null),
    try(local.ingress_outputs.https_listener_arn,      null),
    try(local.ingress_outputs.listener_arn_https_443,  null),
    try(local.ingress_outputs.listener_arns.https_443, null),
    try(local.ingress_outputs.listener_arns.https,     null),
    try(local.ingress_outputs.listeners.https_443.arn, null)
  ])
  
  # Pick the first non-empty candidate; null if none
  effective_https_listener_arn = length(local.https_listener_candidates) > 0 ? local.https_listener_candidates[0] : null

  effective_alb_dns_name = coalesce(
    var.alb_dns_name,
    try(local.ingress_outputs.alb_dns_name, null)
  )

  effective_alb_zone_id = coalesce(
    var.alb_zone_id,
    try(local.ingress_outputs.alb_zone_id, null)
  )

  effective_route53_zone_id = coalesce(
    var.route53_zone_id,
    try(local.ingress_outputs.route53_zone_id, null)
  )

  effective_alb_security_group_id = coalesce(
    var.alb_security_group_id,
    try(local.ingress_outputs.alb_sg_id, null)
  )

 # Build the final container image URI:
  # - If `var.image` is provided, use it as-is (e.g., ".../repo:tag" or with a digest).
  # - Otherwise, compose "<repository_url>:<image_tag>".
  image_uri = var.image != null ? var.image : "${var.repository_url}:${var.image_tag}"

  container_environment = [
    for k, v in var.env : { name = k, value = v }
  ]

  container_secrets = [
    for s in var.secrets : { name = s.name, valueFrom = s.valueFrom }
  ]

  # Use capacity providers if any strategy entries were provided
  use_capacity_providers = length(var.capacity_provider_strategy) > 0
}
