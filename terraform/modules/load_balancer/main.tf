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
# TODO: improve TG creation to use the same configuration for both TG chaging only the name basically
resource "aws_lb_target_group" "this" {
  name       = "${var.project}-lb-tg"
  port       = local.targetPort
  protocol   = local.targetProtocol
  vpc_id     = var.vpc_id
  slow_start = 30
  health_check {
    interval            = 150
    healthy_threshold   = 3
    timeout             = 90
    unhealthy_threshold = 5
    matcher             = "200-308"
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
    description = "allow TCP request from any source from the web"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "allow TCP response to any source from the web"
  }

  tags = {
    Name = "${var.project}-allow-web-access-sg"
  }

  # the egress rules are modified outside this module, this will avoid forever diff between tfstates
  lifecycle {
    ignore_changes = [
      egress
    ]
  }
}

# resource "aws_lb_target_group" "green" {
#   name        = "green"
#   vpc_id      = var.vpc_id
#   port        = local.targetPort
#   protocol    = "HTTP"
#   target_type = "ip"
# }