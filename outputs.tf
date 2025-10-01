output "service_name"      { value = aws_ecs_service.this.name }
output "service_sg_id"     { value = aws_security_group.svc.id }
output "target_group_arn"  { value = aws_lb_target_group.this.arn }
output "ecr_repository_url" {
  value       = coalesce(
                 try(data.terraform_remote_state.ecr_source[0].outputs.ecr_repository_url, null),
                 try(aws_ecr_repository.this[0].repository_url, null)
               )
  description = "ECR repository URI used by this service (created here or read from the dev workspace)."
}
