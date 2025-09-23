output "service_name" { value = aws_ecs_service.this.name }
output "service_arn"  { value = aws_ecs_service.this.arn }

output "task_definition_arn" { value = aws_ecs_task_definition.this.arn }

output "service_sg_id" { value = aws_security_group.service.id }

output "log_group_name" { value = aws_cloudwatch_log_group.this.name }

output "target_group_arn" {
  value       = try(aws_lb_target_group.this[0].arn, null)
  description = "Target group ARN (if exposed via ALB)."
}

output "listener_arn" {
  value       = try(aws_lb_listener.this[0].arn, null)
  description = "Listener ARN (if created)."
}
