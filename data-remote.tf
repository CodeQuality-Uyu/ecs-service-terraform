# Network (VPC/subnets)
data "terraform_remote_state" "network" {
  count   = var.remote_state_org != null && var.remote_state_network_ws != null ? 1 : 0
  backend = "remote"
  config = {
    organization = var.remote_state_org
    workspaces   = { name = var.remote_state_network_ws }
  }
}

# Ingress (ALB/listener/zone/SG)
data "terraform_remote_state" "alb" {
  count   = var.remote_state_org != null && var.remote_state_alb_ws != null ? 1 : 0
  backend = "remote"
  config = {
    organization = var.remote_state_org
    workspaces   = { name = var.remote_state_ingress_ws }
  }
}

# Cluster (ECS cluster ARN)
data "terraform_remote_state" "cluster" {
  count   = var.remote_state_org != null && var.remote_state_cluster_ws != null ? 1 : 0
  backend = "remote"
  config = {
    organization = var.remote_state_org
    workspaces   = { name = var.remote_state_cluster_ws }
  }
}
