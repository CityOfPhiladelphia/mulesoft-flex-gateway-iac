resource "aws_lb_target_group" "flex_gateway" {
  name        = "${var.app_name}-${var.env_name}-flex-gateway"
  port        = 8081
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"
  # Flex gateway may have relatively long outstanding requests so lets use the full 5 minutes
  deregistration_delay = 300

  health_check {
    enabled = true
    port    = 80
    path    = "/custom-health-check.html"
  }
}

resource "aws_autoscaling_attachment" "main" {
  autoscaling_group_name = aws_autoscaling_group.main.id
  lb_target_group_arn    = aws_lb_target_group.flex_gateway.arn
}

resource "aws_lb" "main" {
  name               = "${var.app_name}-${var.env_name}"
  internal           = true
  load_balancer_type = "application"
  subnets            = var.alb_subnet_ids
  security_groups    = [aws_security_group.alb.id]

  enable_deletion_protection = !var.dev_mode
  tags                       = local.default_tags
}

resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.flex_gateway.arn
  }
}
