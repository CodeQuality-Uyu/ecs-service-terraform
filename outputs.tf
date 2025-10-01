output "service_name"      { value = aws_ecs_service.this.name }
output "service_sg_id"     { value = aws_security_group.svc.id }
output "target_group_arn"  { value = aws_lb_target_group.this.arn }
output "repository_url" {
  value       = aws_ecr_repository.this.repository_url
  description = "Full ECR repo URI"
}
