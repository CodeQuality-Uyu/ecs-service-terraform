data "aws_iam_policy_document" "task_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals { type = "Service", identifiers = ["ecs-tasks.amazonaws.com"] }
  }
}

resource "aws_iam_role" "execution" {
  count              = var.execution_role_arn == null && var.create_execution_role ? 1 : 0
  name               = "${var.name}-exec-role"
  assume_role_policy = data.aws_iam_policy_document.task_assume.json
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "exec_managed" {
  count      = var.execution_role_arn == null && var.create_execution_role ? 1 : 0
  role       = aws_iam_role.execution[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "task" {
  count              = var.task_role_arn == null ? 1 : 0
  name               = "${var.name}-task-role"
  assume_role_policy = data.aws_iam_policy_document.task_assume.json
  tags               = var.tags
}

resource "aws_iam_role_policy" "task_inline" {
  count  = var.task_role_arn == null && var.task_role_inline_policy_json != null ? 1 : 0
  name   = "${var.name}-task-inline"
  role   = aws_iam_role.task[0].id
  policy = var.task_role_inline_policy_json
}

locals {
  effective_execution_role_arn = var.execution_role_arn != null ? var.execution_role_arn : (var.create_execution_role ? aws_iam_role.execution[0].arn : null)
  effective_task_role_arn      = var.task_role_arn != null ? var.task_role_arn : aws_iam_role.task[0].arn
}
