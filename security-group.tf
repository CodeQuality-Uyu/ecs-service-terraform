resource "aws_security_group" "service" {
  name        = "${var.name}-svc-sg"
  description = "ECS service SG for ${var.name}"
  vpc_id      = var.vpc_id
  tags        = merge(var.tags, { Name = "${var.name}-svc-sg" })
}

# Egress all
resource "aws_vpc_security_group_egress_rule" "svc_all_egress" {
  security_group_id = aws_security_group.service.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# Ingress from ALB SG to container port (public via ALB)
resource "aws_vpc_security_group_ingress_rule" "from_alb" {
  count                        = var.expose_via_alb && var.alb_security_group_id != null ? 1 : 0
  security_group_id            = aws_security_group.service.id
  referenced_security_group_id = var.alb_security_group_id
  ip_protocol                  = "tcp"
  from_port                    = var.container_port
  to_port                      = var.container_port
}

# Internal-only: allow from selected SGs
resource "aws_vpc_security_group_ingress_rule" "from_internal_sgs" {
  for_each = var.expose_via_alb ? {} : toset(var.allowed_source_sg_ids)
  security_group_id            = aws_security_group.service.id
  referenced_security_group_id = each.value
  ip_protocol                  = "tcp"
  from_port                    = var.container_port
  to_port                      = var.container_port
}
