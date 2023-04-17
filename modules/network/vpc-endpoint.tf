resource "aws_security_group" "vpc_endpoint" {
  name   = "${var.vpc_name}-vpc_endpoint-secgrp"
  vpc_id = var.network.create_vpc ? module.vpc.vpc_id : var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "vpc_endpoint-secgrp-self" {
  security_group_id        = aws_security_group.vpc_endpoint.id
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
  source_security_group_id = aws_security_group.vpc_endpoint.id
}

resource "aws_security_group_rule" "vpc_endpoint-secgrp-cidrs" {
  security_group_id = aws_security_group.vpc_endpoint.id
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = var.vpc_endpoint_allowed_cidrs
}

resource "aws_vpc_endpoint" "ec2" {
  count             = var.vpc_enable_private ? 1 : 0
  vpc_id            = var.network.create_vpc ? module.vpc.vpc_id : var.vpc_id
  service_name      = "com.amazonaws.${var.region}.ec2"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    aws_security_group.vpc_endpoint.id,
  ]

  subnet_ids          = length(var.vpc_endpoint_subnets) > 0 ? var.vpc_endpoint_subnets : aws_subnet.private_subnets.*.id
  private_dns_enabled = true

  tags = {
    Name = "${var.vpc_name}-ep-ec2"
  }
}

resource "aws_vpc_endpoint" "logs" {
  count             = var.vpc_enable_private ? 1 : 0
  vpc_id            = var.network.create_vpc ? module.vpc.vpc_id : var.vpc_id
  service_name      = "com.amazonaws.${var.region}.logs"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    aws_security_group.vpc_endpoint.id,
  ]

  subnet_ids          = length(var.vpc_endpoint_subnets) > 0 ? var.vpc_endpoint_subnets : aws_subnet.private_subnets.*.id
  private_dns_enabled = true

  tags = {
    Name = "${var.vpc_name}-ep-logs"
  }
}

resource "aws_vpc_endpoint" "ecr_api" {
  count             = var.vpc_enable_private ? 1 : 0
  vpc_id            = var.network.create_vpc ? module.vpc.vpc_id : var.vpc_id
  service_name      = "com.amazonaws.${var.region}.ecr.api"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    aws_security_group.vpc_endpoint.id,
  ]

  subnet_ids          = length(var.vpc_endpoint_subnets) > 0 ? var.vpc_endpoint_subnets : aws_subnet.private_subnets.*.id
  private_dns_enabled = true

  tags = {
    Name = "${var.vpc_name}-ep-ecr-api"
  }
}

resource "aws_vpc_endpoint" "ecr_dkr" {
  count             = var.vpc_enable_private ? 1 : 0
  vpc_id            = var.network.create_vpc ? module.vpc.vpc_id : var.vpc_id
  service_name      = "com.amazonaws.${var.region}.ecr.dkr"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    aws_security_group.vpc_endpoint.id,
  ]

  subnet_ids          = length(var.vpc_endpoint_subnets) > 0 ? var.vpc_endpoint_subnets : aws_subnet.private_subnets.*.id
  private_dns_enabled = true

  tags = {
    Name = "${var.vpc_name}-ep-ecr-dkr"
  }
}

resource "aws_vpc_endpoint" "sts" {
  count             = var.vpc_enable_private ? 1 : 0
  vpc_id            = var.network.create_vpc ? module.vpc.vpc_id : var.vpc_id
  service_name      = "com.amazonaws.${var.region}.sts"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    aws_security_group.vpc_endpoint.id,
  ]

  subnet_ids          = length(var.vpc_endpoint_subnets) > 0 ? var.vpc_endpoint_subnets : aws_subnet.private_subnets.*.id
  private_dns_enabled = true

  tags = {
    Name = "${var.vpc_name}-ep-sts"
  }
}

resource "aws_vpc_endpoint" "s3" {
  count             = var.vpc_enable_private ? 1 : 0
  vpc_id            = var.network.create_vpc ? module.vpc.vpc_id : var.vpc_id
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = aws_route_table.private.*.id

  tags = {
    Name = "${var.vpc_name}-ep-s3"
  }
}

resource "aws_vpc_endpoint" "elasticloadbalancing" {
  count             = var.vpc_enable_private ? 1 : 0
  vpc_id            = var.network.create_vpc ? module.vpc.vpc_id : var.vpc_id
  service_name      = "com.amazonaws.${var.region}.elasticloadbalancing"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    aws_security_group.vpc_endpoint.id,
  ]

  subnet_ids          = length(var.vpc_endpoint_subnets) > 0 ? var.vpc_endpoint_subnets : aws_subnet.private_subnets.*.id
  private_dns_enabled = true

  tags = {
    Name = "${var.vpc_name}-ep-elasticloadbalancing"
  }
}

resource "aws_vpc_endpoint" "autoscaling" {
  count             = var.vpc_enable_private ? 1 : 0
  vpc_id            = var.network.create_vpc ? module.vpc.vpc_id : var.vpc_id
  service_name      = "com.amazonaws.${var.region}.autoscaling"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    aws_security_group.vpc_endpoint.id,
  ]

  subnet_ids = length(var.vpc_endpoint_subnets) > 0 ? var.vpc_endpoint_subnets : aws_subnet.private_subnets.*.id


  private_dns_enabled = true

  tags = {
    Name = "${var.vpc_name}-ep-autoscaling"
  }
}

# For OIDC
#resource "aws_vpc_endpoint" "eks" {
#  count             = var.vpc_enable_private ? 1 : 0
#  vpc_id            = var.network.create_vpc ? module.vpc.vpc_id : var.vpc_id
#  service_name      = "com.amazonaws.${var.region}.eks"
#  vpc_endpoint_type = "Interface"
#
#  security_group_ids = [
#    aws_security_group.vpc_endpoint.id,
#  ]
#
#  subnet_ids          = length(var.vpc_endpoint_subnets) > 0 ? var.vpc_endpoint_subnets : aws_subnet.private_subnets.*.id
#  private_dns_enabled = true
#
#  tags = {
#    Name = "${var.vpc_name}-ep-eks"
#  }
#}
