resource "aws_ecr_repository" "this" {
 # Create the repo only when we are the first env (e.g., dev) and
  # there's no repo URL coming from the source workspace.
  count = try(data.terraform_remote_state.ecr_source[0].outputs.ecr_repository_url, null) == null ? 1 : 0

  # repo must be lowercase and follow ECR rules
  name = var.name
  image_scanning_configuration { scan_on_push = true }
  tags = var.tags
}
