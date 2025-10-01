resource "aws_ecr_repository" "this" {
  # repo must be lowercase and follow ECR rules
  name = var.name
  image_scanning_configuration { scan_on_push = true }
  tags = var.tags
}
