# Host-based rule on shared HTTPS :443 listener
resource "aws_lb_listener_rule" "host_443" {
  count        = var.expose_via_alb ? 1 : 0
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
    precondition {
      condition     = var.https_listener_arn != null && length(var.hostnames) > 0 && var.listener_rule_priority != null
      error_message = "When expose_via_alb=true you must set https_listener_arn, hostnames and listener_rule_priority."
    }
  }
}
