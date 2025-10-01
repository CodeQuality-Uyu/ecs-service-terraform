# Trust policy for ECS tasks
data "aws_iam_policy_document" "ecs_tasks_assume_exec" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# Create the EXECUTION role only when you didn't pass one
resource "aws_iam_role" "execution" {
  count              = var.create_execution_role && var.execution_role_arn == null ? 1 : 0
  name               = "tf-${var.environment}-${var.name}-exec"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_assume_exec.json
  tags               = var.tags
}

# Wait a bit for IAM to propagate
resource "time_sleep" "iam_propagation" {
  count         = var.create_execution_role && var.execution_role_arn == null ? 1 : 0
  depends_on    = [aws_iam_role.execution]
  create_duration = "15s"
}

resource "aws_iam_role_policy_attachment" "exec_base" {
  count      = var.create_execution_role && var.execution_role_arn == null ? 1 : 0
  role       = aws_iam_role.execution[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  depends_on = [time_sleep.iam_propagation]   # 👈 ensure delay before attach
}

resource "aws_iam_role_policy_attachment" "exec_ssm" {
  count      = var.create_execution_role && var.execution_role_arn == null && var.enable_execute_command ? 1 : 0
  role       = aws_iam_role.execution[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  depends_on = [time_sleep.iam_propagation]   # 👈 ensure delay before attach
}
