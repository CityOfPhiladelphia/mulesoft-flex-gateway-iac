// EC2 security group
resource "aws_security_group" "ec2" {
  name        = "${var.app_name}-${var.env_name}-ec2"
  description = "SG for EC2"
  vpc_id      = var.vpc_id

  tags = merge(local.default_tags, { Name = "${var.app_name}-${var.env_name}-ec2" })
}

resource "aws_vpc_security_group_egress_rule" "ec2_outbound_all_to_everywhere" {
  security_group_id = aws_security_group.ec2.id
  description       = "Full outbound access"

  ip_protocol = -1
  cidr_ipv4   = "0.0.0.0/0"
}

# For health check
resource "aws_vpc_security_group_ingress_rule" "ec2_inbound_http_from_alb" {
  security_group_id = aws_security_group.ec2.id
  description       = "Inbound http access from ALB"

  ip_protocol                  = "tcp"
  from_port                    = 80
  to_port                      = 80
  referenced_security_group_id = aws_security_group.alb.id
}

resource "aws_vpc_security_group_ingress_rule" "ec2_inbound_flex_gateway_from_alb" {
  security_group_id = aws_security_group.ec2.id
  description       = "Inbound http access from ALB"

  ip_protocol                  = "tcp"
  from_port                    = 8081
  to_port                      = 8081
  referenced_security_group_id = aws_security_group.alb.id
}

// ALB security group
resource "aws_security_group" "alb" {
  name        = "${var.app_name}-${var.env_name}-alb"
  description = "SG for ALB"
  vpc_id      = var.vpc_id

  tags = merge(local.default_tags, { Name = "${var.app_name}-${var.env_name}-alb" })
}

resource "aws_vpc_security_group_ingress_rule" "alb_inbound_https_from_anywhere" {
  security_group_id = aws_security_group.alb.id
  description       = "Inbound https access from anywhere"

  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443
  cidr_ipv4   = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "alb_inbound_http_from_anywhere" {
  security_group_id = aws_security_group.alb.id
  description       = "Inbound http access from anywhere"

  ip_protocol = "tcp"
  from_port   = 80
  to_port     = 80
  cidr_ipv4   = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "alb_outbound_all_to_ec2" {
  security_group_id = aws_security_group.alb.id
  description       = "Full outbound access to ec2"

  ip_protocol                  = "-1"
  referenced_security_group_id = aws_security_group.ec2.id
}

// Redis security group
resource "aws_security_group" "redis" {
  name        = "${var.app_name}-${var.env_name}-redis"
  description = "SG for Elasticache Redis"
  vpc_id      = var.vpc_id

  tags = merge(local.default_tags, { Name = "${var.app_name}-${var.env_name}-redis" })
}

resource "aws_vpc_security_group_ingress_rule" "redis_inbound_redis_from_ec2" {
  security_group_id = aws_security_group.redis.id
  description       = "Inbound REDIS access from EC2"

  ip_protocol                  = "tcp"
  from_port                    = 6379
  to_port                      = 6379
  referenced_security_group_id = aws_security_group.ec2.id
}

