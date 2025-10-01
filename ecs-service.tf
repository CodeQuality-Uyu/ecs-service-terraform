resource "aws_ecs_service" "this" {
  name                               = "${var.environment}-${var.name}"
  cluster                            = local.effective_cluster_arn
  task_definition                    = aws_ecs_task_definition.this.arn
  desired_count                      = var.desired_count
  enable_execute_command             = var.enable_execute_command
  health_check_grace_period_seconds  = var.health_check_grace_period
  platform_version                   = var.platform_version
  propagate_tags                     = "SERVICE"

  # If no capacity providers specified, use launch_type=FARGATE
  launch_type = local.use_capacity_providers ? null : "FARGATE"

  dynamic "capacity_provider_strategy" {
    for_each = local.use_capacity_providers ? var.capacity_provider_strategy : []
    content {
      capacity_provider = capacity_provider_strategy.value.capacity_provider
      base              = try(capacity_provider_strategy.value.base, null)
      weight            = try(capacity_provider_strategy.value.weight, null)
    }
  }

  network_configuration {
    subnets         = local.effective_subnet_ids
    security_groups = [aws_security_group.svc.id]
    assign_public_ip = var.assign_public_ip
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.this.arn
    container_name   = "${var.environment}-${var.name}"
    container_port   = var.container_port
  }

  deployment_minimum_healthy_percent = var.deployment_min_healthy_percent
  deployment_maximum_percent         = var.deployment_max_percent

  lifecycle {
    ignore_changes = [desired_count] # optional: let autoscaling update it
  }

  tags = var.tags
}
