terraform {
  required_providers { aws = { source = "hashicorp/aws", version = ">= 5.0" } }
}

data "aws_region" "current" {}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "lg" {
  name              = "/ecs/${var.env}/${var.service_name}"
  retention_in_days = var.log_retention_days
}

# IAM roles
data "aws_iam_policy_document" "assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
      }
  }
}

resource "aws_iam_role" "exec" {
  name               = "${var.env}-${var.service_name}-exec"
  assume_role_policy = data.aws_iam_policy_document.assume.json
}
resource "aws_iam_role_policy_attachment" "exec" {
  role       = aws_iam_role.exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "task" {
  name               = "${var.env}-${var.service_name}-task"
  assume_role_policy = data.aws_iam_policy_document.assume.json
}

# ---- Get the latest container_definitions so TF won't revert the CI image ----
data "aws_ecs_task_definition" "latest" {
  count           = var.bootstrap ? 0 : 1
  task_definition = var.family
}

# Build initial container JSON only for bootstrap
data "aws_ecr_repository" "repo" {
  count = var.bootstrap ? 1 : 0
  name  = var.ecr_repo_name
}

locals {
  container_bootstrap = jsonencode([{
    name      = var.service_name
    image     = "${var.bootstrap ? data.aws_ecr_repository.repo[0].repository_url : ""}:${var.bootstrap ? var.initial_image_tag : ""}"
    essential = true
    portMappings = [{ containerPort = var.container_port, hostPort = var.container_port, protocol = "tcp" }]
    logConfiguration = {
      logDriver = "awslogs",
      options = {
        awslogs-group         = aws_cloudwatch_log_group.lg.name
        awslogs-region        = data.aws_region.current.name
        awslogs-stream-prefix = var.service_name
      }
    }
  }])

  container_json = var.bootstrap ? local.container_bootstrap : data.aws_ecs_task_definition.latest[0].container_definitions
}

# Task definition (Terraform controls CPU/MEM; image preserved from latest unless bootstrap)
resource "aws_ecs_task_definition" "td" {
  family                   = var.family
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = aws_iam_role.exec.arn
  task_role_arn            = aws_iam_role.task.arn

  container_definitions = local.container_json
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture = "X86_64"
    }
}

# ALB target group (optional)
resource "aws_lb_target_group" "tg" {
  count                = var.expose_via_alb ? 1 : 0
  name                 = substr("${var.env}-${var.service_name}", 0, 32)
  port                 = var.container_port
  protocol             = "HTTP"
  vpc_id               = split(":", var.ecs_cluster_arn)[4] != "" ? null : null # placeholder; not used because we attach by ARN in service
  target_type          = "ip"
  health_check { path = "/" }
  lifecycle { create_before_destroy = true }
}

# ECS Service – track the latest ACTIVE revision family so TF won’t roll back CI deploys
resource "aws_ecs_service" "svc" {
  name                    = "${var.env}-${var.service_name}"
  cluster                 = var.ecs_cluster_arn
  task_definition         = data.aws_ecs_task_definition.latest[*].arn != [] ? data.aws_ecs_task_definition.latest[0].arn : aws_ecs_task_definition.td.arn
  desired_count           = var.desired_count
  launch_type             = "FARGATE"
  enable_execute_command  = true
  propagate_tags          = "SERVICE"
  enable_ecs_managed_tags = true

  network_configuration {
    subnets         = var.subnet_ids
    security_groups = var.security_group_ids
    assign_public_ip = true
  }

  dynamic "load_balancer" {
    for_each = var.expose_via_alb ? [1] : []
    content {
      target_group_arn = aws_lb_target_group.tg[0].arn
      container_name   = var.service_name
      container_port   = var.container_port
    }
  }
}

# allow ALB -> service on container_port
resource "aws_security_group_rule" "svc_ingress_from_alb" {
  type                     = "ingress"
  from_port                = var.container_port
  to_port                  = var.container_port
  protocol                 = "tcp"
  security_group_id        = var.service_security_group_id
  source_security_group_id = var.alb_security_group_id
}

# open external listener port on the ALB SG
resource "aws_security_group_rule" "alb_ingress_service_port" {
  type              = "ingress"
  security_group_id = var.alb_security_group_id
  from_port         = var.listener_port
  to_port           = var.listener_port
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"] # tighten if needed
}

# per-service listener (port-based)
resource "aws_lb_listener" "svc_listener" {
  load_balancer_arn = var.alb_arn
  port              = var.listener_port
  protocol          = var.listener_protocol

  ssl_policy      = var.listener_protocol == "HTTPS" ? "ELBSecurityPolicy-TLS13-1-2-2021-06" : null
  certificate_arn = var.listener_protocol == "HTTPS" ? var.certificate_arn : null

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}
