data "aws_iam_policy_document" "ecs_tasks_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals { type = "Service", identifiers = ["ecs-tasks.amazonaws.com"] }
  }
}

# Create task role only if none provided
resource "aws_iam_role" "task" {
  count              = var.task_role_arn == null ? 1 : 0
  name               = "tf-${var.name}-task"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_assume.json
  tags               = var.tags
}

# Optional inline policy for app needs (Secrets, S3, etc.)
resource "aws_iam_role_policy" "task_inline" {
  count  = var.task_role_arn == null && var.task_role_inline_policy_json != null ? 1 : 0
  name   = "tf-${var.name}-task-inline"
  role   = aws_iam_role.task[0].id
  policy = var.task_role_inline_policy_json
}

# If you use ECS Exec, attach SSM permissions to the TASK role
resource "aws_iam_role_policy_attachment" "task_ssm_exec" {
  count      = var.task_role_arn == null && var.enable_execute_command ? 1 : 0
  role       = aws_iam_role.task[0].name
  # Grants ssmmessages permissions used by ECS Exec
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
