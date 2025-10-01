resource "aws_lb_listener_rule" "https_host" {
  count        = var.expose_via_alb && local.effective_https_listener_arn != null && length(var.hostnames) > 0 ? 1 : 0
  listener_arn = local.effective_https_listener_arn
  priority     = var.listener_rule_priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }

  condition {
    host_header { values = var.hostnames }
  }

  lifecycle {
    ignore_changes = [ tags ]
  }

  tags = var.tags
}
