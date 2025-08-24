resource "aws_ecr_repository" "this" {
  name                 = var.repo_name
  image_tag_mutability = "IMMUTABLE"
  force_delete         = var.force_destroy

  image_scanning_configuration { scan_on_push = var.scan_on_push }
  encryption_configuration     { encryption_type = "AES256" }
}

resource "aws_ecr_lifecycle_policy" "keep_n" {
  repository = aws_ecr_repository.this.name
  policy = jsonencode({
    rules = [{
      rulePriority = 1,
      description  = "Keep last N images",
      selection = { tagStatus="any", countType="imageCountMoreThan", countNumber=var.keep_last },
      action = { type = "expire" }
    }]
  })
}

output "repository_name" { value = aws_ecr_repository.this.name }
output "repository_url"  { value = aws_ecr_repository.this.repository_url }
