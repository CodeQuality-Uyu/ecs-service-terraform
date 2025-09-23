locals {
  effective_image = var.image != null ? var.image : "${var.repository_url}:${var.image_tag}"
}

resource "aws_ecs_task_definition" "this" {
  family                   = var.name
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = local.effective_execution_role_arn
  task_role_arn            = local.effective_task_role_arn

  container_definitions = jsonencode([
    {
      name      = var.name
      image     = local.effective_image
      essential = true
      portMappings = [{ containerPort = var.container_port, protocol = "tcp" }]
      environment = [for k, v in var.env : { name = k, value = v }]
      secrets     = [for s in var.secrets : { name = s.name, valueFrom = s.valueFrom }]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.this.name
          awslogs-region        = data.aws_region.current.name
          awslogs-stream-prefix = var.name
        }
      }
    }
  ])

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  tags = var.tags
}
