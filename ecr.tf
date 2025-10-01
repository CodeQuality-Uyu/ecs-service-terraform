# ECR source-of-truth: read the repo URL from the first env (e.g., dev) service workspace
data "terraform_remote_state" "ecr_source" {
  count   = var.remote_state_org != null && var.remote_state_ecr_ws != null ? 1 : 0
  backend = "remote"
  config = {
    organization = var.remote_state_org
    workspaces   = { name = var.remote_state_ecr_ws }
  }
}
