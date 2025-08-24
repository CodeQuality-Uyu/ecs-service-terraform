output "service_name" { value = aws_ecs_service.svc.name }
output "service_arn"  { value = aws_ecs_service.svc.arn }
output "family"       { value = var.family }
