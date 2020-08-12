locals {
  targetPort     = var.https_enabled ? 443 : 80
  targetProtocol = var.https_enabled ? "HTTPS" : "HTTP"
}

resource "aws_lb" "this" {
  name               = "${var.project}-lb"
  internal           = false
  load_balancer_type = "application"
  subnets            = var.lb_subnets

  security_groups = [
    aws_security_group.allow_web.id
  ]

  tags = {
    Name = "${var.project}-lb"
  }
}

resource "aws_lb_target_group" "this" {
  name     = "${var.project}-lb-tg"
  port     = local.targetPort
  protocol = local.targetProtocol
  vpc_id   = var.vpc_id
  slow_start = 30
  health_check {
    healthy_threshold = 5
    timeout = 15
    unhealthy_threshold = 3
  }
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  port              = local.targetPort
  protocol          = local.targetProtocol
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}

resource "aws_security_group" "allow_web" {
  name   = "${var.project} - allow web access"
  vpc_id = var.vpc_id

  ingress {
    from_port   = local.targetPort
    to_port     = local.targetPort
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # TODO: restrict the egress, probably it would only need access to EC2 instances SG
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project}-allow-web-access-sg"
  }
}

resource "aws_lb_target_group" "green" {
  name        = "green"
  vpc_id      = var.vpc_id
  port        = local.targetPort
  protocol    = "HTTP"
  target_type = "ip"
}