resource "aws_lb_listener_rule" "host_443" {
  # create only when exposing and we have hostnames
  count        = var.expose_via_alb && length(var.hostnames) > 0 ? 1 : 0

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
      # ✅ check the effective (remote-state or explicit) value, not the raw var
      condition = local.effective_https_listener_arn != null
               && length(var.hostnames) > 0
               && var.listener_rule_priority != null
      error_message = "When expose_via_alb = true you must provide https_listener_arn explicitly OR set remote_state_org + (remote_state_ingress_ws|remote_state_alb_ws) so the module can resolve it; also set hostnames and listener_rule_priority."
    }
  }

  tags = var.tags
}
