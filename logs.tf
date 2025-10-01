resource "aws_cloudwatch_log_group" "this" {
  name              = "/ecs/${var.environment}-${var.name}"
  retention_in_days = var.log_retention_days
  tags              = var.tags
}
