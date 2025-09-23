# ecs-service (host-based routing)

Crea **un servicio ECS Fargate** y lo conecta a:
- un **listener 443 compartido** del ALB por **hostname** (host-based), o
- queda **interno** (sin ALB) si `expose_via_alb = false`.

## Entradas clave
- `cluster_arn`, `subnet_ids`, `vpc_id`, `alb_security_group_id`
- `cpu`, `memory`, `container_port`, `desired_count`, `image` o `repository_url` + `image_tag`
- **Host-based**:
  - `https_listener_arn` (del módulo ingress)
  - `hostnames` (p. ej. `["users.dev.ecolors.app"]`)
  - `listener_rule_priority` (única por listener)
  - `route53_zone_id`, `alb_dns_name`, `alb_zone_id` (si `create_dns_records = true`)
- Interno: `expose_via_alb = false` + `allowed_source_sg_ids` (SGs que pueden llamar)

## Ejemplo (dev, público por host)
```hcl
module "users_web_api" {
  source       = "./modules/ecs-service"
  name         = "users-web-api"

  cluster_arn  = data.terraform_remote_state.cluster.outputs.ecs_cluster_arn
  subnet_ids   = data.terraform_remote_state.network.outputs.public_subnet_ids
  vpc_id       = data.terraform_remote_state.network.outputs.vpc_id

  cpu            = 256
  memory         = 512
  container_port = 7190
  desired_count  = 2

  repository_url = aws_ecr_repository.users.repository_url
  image_tag      = var.image_tag

  # Host-based routing
  expose_via_alb         = true
  alb_security_group_id  = data.terraform_remote_state.ingress.outputs.alb_sg_id
  https_listener_arn     = data.terraform_remote_state.ingress.outputs.https_443_listener_arn
  hostnames              = ["users.dev.ecolors.app"]
  listener_rule_priority = 1010
  create_dns_records     = true
  route53_zone_id        = data.terraform_remote_state.ingress.outputs.route53_zone_id
  alb_dns_name           = data.terraform_remote_state.ingress.outputs.alb_dns_name
  alb_zone_id            = data.terraform_remote_state.ingress.outputs.alb_zone_id

  tags = { Project = "EColors", Env = "dev", Service = "users-web-api" }
}
