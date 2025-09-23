# Target Group (only when exposing via ALB)
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

# Listener on specified port (per-service port) – HTTP or HTTPS
resource "aws_lb_listener" "this" {
  count             = var.expose_via_alb ? 1 : 0
  load_balancer_arn = var.alb_arn
  port              = var.listener_port
  protocol          = var.listener_protocol

  dynamic "default_action" {
    for_each = [1]
    content {
      type             = "forward"
      target_group_arn = aws_lb_target_group.this[0].arn
    }
  }

  ssl_policy      = var.listener_protocol == "HTTPS" ? "ELBSecurityPolicy-2016-08" : null
  certificate_arn = var.listener_protocol == "HTTPS" ? var.certificate_arn : null

  lifecycle {
    precondition {
      condition     = var.listener_protocol == "HTTP" || (var.listener_protocol == "HTTPS" && var.certificate_arn != null)
      error_message = "certificate_arn is required when listener_protocol is HTTPS"
    }
  }
}

# Optional: HTTP redirect on same port to HTTPS
resource "aws_lb_listener" "redirect_http" {
  count             = var.expose_via_alb && var.listener_protocol == "HTTPS" && var.redirect_http_to_https ? 1 : 0
  load_balancer_arn = var.alb_arn
  port              = var.listener_port
  protocol          = "HTTP"
  default_action {
    type = "redirect"
    redirect {
      port        = tostring(var.listener_port)
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}
