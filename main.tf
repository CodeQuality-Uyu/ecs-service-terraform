# Pull shared env infra from clusters workspace
data "terraform_remote_state" "cluster" {
  backend = "remote"
  config = {
    organization = var.clusters_org
    workspaces = { name = var.clusters_ws_name } # e.g., clusters-dev
  }
}

# Create (or ensure) the ECR repository for this service
module "ecr" {
  source     = "./modules/ecr-repo"
  repo_name  = var.ecr_repo_name
  keep_last  = 20
  scan_on_push = true
}

# One stable family per env+service, e.g., "dev-users"
locals {
  family        = "${var.env}-${var.service_name}"
  cluster_arn   = data.terraform_remote_state.cluster.outputs.ecs_cluster_arn
  vpc_id        = data.terraform_remote_state.cluster.outputs.vpc_id
  subnets       = data.terraform_remote_state.cluster.outputs.service_subnet_ids
  svc_sg_id     = data.terraform_remote_state.cluster.outputs.service_security_group_id
  listener_arn  = try(data.terraform_remote_state.cluster.outputs.alb_listener_arn, null)
}

module "svc" {
  source = "./modules/ecs-service"

  aws_region     = var.aws_region
  env            = var.env
  service_name   = var.service_name
  family         = local.family

  ecs_cluster_arn = local.cluster_arn
  subnet_ids       = local.subnets
  security_group_ids = [local.svc_sg_id]

  cpu            = var.cpu
  memory         = var.memory
  desired_count  = var.desired_count

  # Bootstrap only on first run (requires an existing image tag in the repo)
  bootstrap          = var.bootstrap
  ecr_repo_name      = module.ecr.repository_name
  initial_image_tag  = var.initial_image_tag
  container_port     = var.container_port

  # Optional ALB exposure (target group + listener rule on shared ALB)
  expose_via_alb   = var.expose_via_alb
  alb_listener_arn = local.listener_arn
  path_pattern     = var.path_pattern
  rule_priority    = var.priority
}
