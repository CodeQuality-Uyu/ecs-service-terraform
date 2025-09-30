locals {
  image_uri = var.image != null ? var.image : "${var.repository_url}:${var.image_tag}"

  container_environment = [
    for k, v in var.env : { name = k, value = v }
  ]

  container_secrets = [
    for s in var.secrets : { name = s.name, valueFrom = s.valueFrom }
  ]

  # convenience
  use_capacity_providers = length(var.capacity_provider_strategy) > 0
}
