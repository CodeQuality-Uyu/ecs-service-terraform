output "service_name" { value = aws_ecs_service.svc.name }
output "service_arn"  { value = aws_ecs_service.svc.arn }
output "family"       { value = var.family }

output "listener_arn"     { value = aws_lb_listener.svc_listener.arn }
output "target_group_arn" { value = aws_lb_target_group.tg.arn }
