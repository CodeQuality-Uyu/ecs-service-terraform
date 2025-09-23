resource "aws_ecs_service" "this" {
  name                   = var.name
  cluster                = var.cluster_arn
  desired_count          = var.desired_count
  task_definition        = aws_ecs_task_definition.this.arn
  platform_version       = var.platform_version
  enable_execute_command = var.enable_execute_command

  deployment_minimum_healthy_percent = var.deployment_min_healthy_percent
  deployment_maximum_percent         = var.deployment_max_percent
  health_check_grace_period_seconds  = var.health_check_grace_period

  dynamic "capacity_provider_strategy" {
    for_each = var.capacity_provider_strategy
    content {
      capacity_provider = capacity_provider_strategy.value.capacity_provider
      base              = try(capacity_provider_strategy.value.base, 0)
      weight            = try(capacity_provider_strategy.value.weight, 1)
    }
  }

  launch_type = length(var.capacity_provider_strategy) == 0 ? "FARGATE" : null

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [aws_security_group.service.id]
    assign_public_ip = var.assign_public_ip
  }

  dynamic "load_balancer" {
    for_each = var.expose_via_alb ? [1] : []
    content {
      target_group_arn = aws_lb_target_group.this[0].arn
      container_name   = var.name
      container_port   = var.container_port
    }
  }

  lifecycle {
    ignore_changes = [task_definition]
  }

  tags = var.tags
}
