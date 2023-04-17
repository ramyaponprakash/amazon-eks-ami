resource "aws_security_group" "squidproxy" {
  name   = "${var.vpc_name}-squidproxy"
  vpc_id = var.vpc_id
  #description = "Allows traffic from and to the EC2 instances

  dynamic "ingress" {
    for_each = var.squid_secgrp_ingress_cidr
    content {
      cidr_blocks = ingress.value.cidrs
      protocol    = "tcp"
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      description = ingress.value.description
    }
  }

  dynamic "ingress" {
    for_each = var.squid_secgrp_ingress_secgrp
    content {
      security_groups = ingress.value.secgrp_ids
      protocol        = "tcp"
      from_port       = ingress.value.port
      to_port         = ingress.value.port
      description     = ingress.value.description
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.vpc_name}-squidproxy"
  }
}
