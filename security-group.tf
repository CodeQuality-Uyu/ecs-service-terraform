resource "aws_security_group" "svc" {
  name        = "${var.name}-svc-sg"
  description = "SG for ${var.name} tasks"
  vpc_id      = var.vpc_id
  tags        = merge(var.tags, { Name = "${var.name}-svc-sg" })
}

# allow ALB → service (only when exposing via ALB)
resource "aws_vpc_security_group_ingress_rule" "from_alb" {
  count                    = var.expose_via_alb && var.alb_security_group_id != null ? 1 : 0
  security_group_id        = aws_security_group.svc.id
  referenced_security_group_id = var.alb_security_group_id
  ip_protocol              = "tcp"
  from_port                = var.container_port
  to_port                  = var.container_port
}

# extra SG sources (internal callers, other services, etc.)
resource "aws_vpc_security_group_ingress_rule" "from_extra_sgs" {
  for_each                 = toset(var.allowed_source_sg_ids)
  security_group_id        = aws_security_group.svc.id
  referenced_security_group_id = each.value
  ip_protocol              = "tcp"
  from_port                = var.container_port
  to_port                  = var.container_port
}

resource "aws_vpc_security_group_egress_rule" "all" {
  security_group_id = aws_security_group.svc.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}
