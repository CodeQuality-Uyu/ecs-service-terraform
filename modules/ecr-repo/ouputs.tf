output "repository_name" {
  description = "ECR repository name."
  value       = aws_ecr_repository.this.name
}

output "repository_url" {
  description = "Fully qualified ECR repository URL."
  value       = aws_ecr_repository.this.repository_url
}

output "repository_arn" {
  description = "ARN of the ECR repository."
  value       = aws_ecr_repository.this.arn
}

output "registry_id" {
  description = "AWS account/registry ID that owns the repository."
  value       = aws_ecr_repository.this.registry_id
}

output "lifecycle_policy_id" {
  description = "Identifier of the applied lifecycle policy."
  value       = aws_ecr_lifecycle_policy.keep_n.id
}

output "keep_last" {
  description = "Number of images retained by the lifecycle policy (echo of input)."
  value       = var.keep_last
}
