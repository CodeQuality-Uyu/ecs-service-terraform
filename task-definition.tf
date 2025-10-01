resource "aws_ecs_task_definition" "this" {
  family                   = "${var.environment}-${var.name}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = tostring(var.cpu)
  memory                   = tostring(var.memory)

  execution_role_arn = coalesce(
    var.execution_role_arn,
    try(aws_iam_role.execution[0].arn, null)
  )

    # ✅ Pick the provided task role, else the one we just created
  task_role_arn = coalesce(
    var.task_role_arn,
    try(aws_iam_role.task[0].arn, null))
  

  container_definitions = jsonencode([
    {
      name       = "${var.environment}-${var.name}"
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
          awslogs-stream-prefix = "${var.environment}-${var.name}"
        }
      },
      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost:${var.container_port}${var.health_path} || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 10
      }
    }
  ])

  lifecycle {
    precondition {
      condition     = local.repo_url != null
      error_message = "No ECR repo resolved. Dev env must create it (or provide repository_url)."
    }
  }

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  tags = var.tags
}
