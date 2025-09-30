resource "aws_ecs_task_definition" "this" {
  family                   = var.name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = tostring(var.cpu)
  memory                   = tostring(var.memory)

  execution_role_arn = var.execution_role_arn != null
    ? var.execution_role_arn
    : (var.create_execution_role ? aws_iam_role.execution[0].arn : null)

  task_role_arn = var.task_role_arn

  container_definitions = jsonencode([
    {
      name       = var.name
      image      = local.image_uri
      essential  = true
      portMappings = [{ containerPort = var.container_port, hostPort = var.container_port, protocol = "tcp" }]

      environment = local.container_environment
      secrets     = local.container_secrets

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.this.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = var.name
        }
      }

      healthCheck = {
        command     = "/health"
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 10
      }
    }
  ])

  lifecycle {
    precondition {
      condition     = local.image_uri != null && local.image_uri != ""
      error_message = "Set either `image` (full URI) OR `repository_url` + `image_tag`."
    }
  }

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  tags = var.tags
}
