resource "aws_ecs_task_definition" "nginx" {
  family                = "service"
  container_definitions = file("task-definitions/service.json")
}

resource "aws_ecs_cluster" "nginx" {
  name = "nginx-cluster"
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_codedeploy_app" "this" {
  compute_platform = "ECS"
  name             = "nginx"
}

resource "aws_codedeploy_deployment_config" "this" {
  deployment_config_name = "${aws_codedeploy_app.this.name}-config"
  compute_platform = "ECS"
  traffic_routing_config {
      type = "AllAtOnce"
  }
}

resource "aws_codedeploy_deployment_group" "this" {
  app_name               = aws_codedeploy_app.this.name
  deployment_group_name  = "bar"
  service_role_arn       = "arn:aws:iam::097922957316:role/test-codeploy"
  deployment_config_name = aws_codedeploy_deployment_config.this.id

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
    }

    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 5
    }
  }

  ecs_service {
    cluster_name = aws_ecs_cluster.nginx.name
    service_name = aws_ecs_service.nginx.name
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  load_balancer_info {
    target_group_pair_info {
        prod_traffic_route {
            listener_arns = [module.load_balancer.listener_arn]
        }
        target_group {
            name = module.load_balancer.target_group_name
        }

        target_group {
            name = module.load_balancer.target_group_test_name
        }
    }
  }

}

resource "aws_ecs_service" "nginx" {
  name                    = "nginx-service"
  task_definition         = aws_ecs_task_definition.nginx.arn
  desired_count           = 3
  cluster                 = aws_ecs_cluster.nginx.id
  iam_role                = "arn:aws:iam::097922957316:role/aws-service-role/ecs.amazonaws.com/AWSServiceRoleForECS"
  enable_ecs_managed_tags = true

  deployment_controller {
    type = "CODE_DEPLOY"
  }

  load_balancer {
    target_group_arn = module.load_balancer.target_group_arn
    container_name   = "nginx"
    container_port   = 80
  }

  ordered_placement_strategy {
    type  = "binpack"
    field = "cpu"
  }
}

module "container_registry" {
  source          = "../../modules/container_registry"
  repository_name = "nginx"
}

module "load_balancer" {
  source        = "../../modules/load_balancer"
  lb_subnets    = var.lb_subnets
  vpc_id        = var.vpc_id
  https_enabled = false
}

resource "aws_autoscaling_group" "devops" {
  desired_capacity    = 2
  max_size            = 2
  min_size            = 1
  vpc_zone_identifier = var.lb_subnets

  launch_template {
    id      = aws_launch_template.devops.id
    version = "$Latest"
  }
}

resource "aws_autoscaling_attachment" "this" {
  autoscaling_group_name = aws_autoscaling_group.devops.id
  alb_target_group_arn   = module.load_balancer.target_group_arn
}

resource "aws_security_group" "allow_internet" {
  name   = "allow web access sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

#   ingress {
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}