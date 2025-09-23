# Target Group (ip targets for Fargate)
resource "aws_lb_target_group" "this" {
  count       = var.expose_via_alb ? 1 : 0
  name        = substr(replace("${var.name}-tg", ".", "-"), 0, 32)
  port        = var.container_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    path                = var.health_path
    healthy_threshold   = 2
    unhealthy_threshold = 3
    interval            = 30
    timeout             = 5
    matcher             = "200-399"
  }

  deregistration_delay = 15
  tags                 = var.tags
}

# Host-based rule on shared HTTPS :443 listener
resource "aws_lb_listener_rule" "host_443" {
  count        = var.expose_via_alb ? 1 : 0
  listener_arn = var.https_listener_arn
  priority     = var.listener_rule_priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this[0].arn
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
