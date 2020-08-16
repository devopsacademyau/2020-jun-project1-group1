# ECS ports is random so we should allow the ephemeral port range from ALB: https://aws.amazon.com/premiumsupport/knowledge-center/dynamic-port-mapping-ecs/
resource "aws_security_group" "this" {
  name   = "ecs-access-security-group"
  vpc_id = var.vpc_id

  ingress {
    # from_port   = 32768
    from_port = 0
    to_port   = 65535
    protocol  = "tcp"
    security_groups = [
      var.lb_security_group
    ]
    description = "ALB inbound - the ECS ports is set as random and can be any value between 32768-65535"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project-name}-ecs"
  }

  lifecycle {
    ignore_changes = [
      egress
    ]
  }
}

resource "aws_security_group_rule" "lb_allow_egress" {
  type                     = "egress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  security_group_id        = var.lb_security_group
  source_security_group_id = aws_security_group.this.id
  description              = "allow tcp egress to any port from the ECR security group"
}

resource "aws_iam_role" "ecs-instance-role" {
  name               = "ecs-instance-role"
  path               = "/"
  assume_role_policy = <<EOF
{
"Version": "2012-10-17",
"Statement": [
  {
    "Effect": "Allow",
    "Principal": {
      "Service": [
        "ec2.amazonaws.com",
        "ecs-tasks.amazonaws.com"
      ]
    },
    "Action": "sts:AssumeRole"
  }
]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs-instance-role-attachment" {
  role       = aws_iam_role.ecs-instance-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

data "aws_iam_role" "ecs" {
  name = "AWSServiceRoleForECS"
}

resource "aws_iam_role_policy" "this" {
  name = "${var.project-name}-iam_role_policy"
  role = aws_iam_role.ecs-instance-role.id

  policy = <<-EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
          "ec2:DescribeTags",
          "ecs:CreateCluster",
          "ecs:DeregisterContainerInstance",
          "ecs:DiscoverPollEndpoint",
          "ecs:Poll",
          "ecs:RegisterContainerInstance",
          "ecs:StartTelemetrySession",
          "ecs:UpdateContainerInstancesState",
          "ecs:Submit*",
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
      ],
      "Resource": "*"
    },
    {
      "Sid": "AllowAccessToSSMParameters",
      "Effect": "Allow",
      "Action": [
        "ssm:GetParameters"
      ],
      "Resource": "*"
    }
  ]
}
  EOF
}

resource "aws_iam_instance_profile" "ecs-instance-profile" {
  name = "ecs-instance-profile"
  role = aws_iam_role.ecs-instance-role.id
}

resource "aws_launch_template" "this" {
  name_prefix   = var.project-name
  image_id      = var.image_id
  instance_type = var.instance_type
  key_name      = var.instance_keypair
  iam_instance_profile {
    arn = aws_iam_instance_profile.ecs-instance-profile.arn
  }
  network_interfaces {
    # associate_public_ip_address = true
    delete_on_termination = true
    security_groups = [
      aws_security_group.this.id
    ]
  }
  tag_specifications {
    resource_type = "instance"
    tags = merge(var.common_tags, {
      Name = "${var.project-name}-instance"
    })
  }

  user_data = base64encode(<<EOF
#! /bin/bash
yum update -y
echo ECS_CLUSTER=${aws_ecs_cluster.ecs-cluster.name} >> /etc/ecs/ecs.config;echo ECS_BACKEND_HOST= >> /etc/ecs/ecs.config;
  EOF
  )
}


# create auto scaling group
resource "aws_autoscaling_group" "ecs-autoscaling-group" {
  name                      = "ecs-autoscaling-group"
  max_size                  = var.max-size
  min_size                  = var.min-size
  wait_for_capacity_timeout = 0
  desired_capacity          = var.desired_count < var.min-size ? var.min-size : var.desired_count
  # vpc_zone_identifier       = [var.subnet-public-1, var.subnet-public-2]
  vpc_zone_identifier       = var.private_subnets
  health_check_type         = "EC2"
  target_group_arns         = [var.target_group_arn]
  health_check_grace_period = 300
  default_cooldown          = 300
  termination_policies      = ["OldestInstance"]
  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }
  tag {
    key                 = "Name"
    value               = "${var.project-name}-ECS"
    propagate_at_launch = true
  }

  lifecycle {
    ignore_changes = [
      desired_capacity
    ]
  }
}



#create auto scaling policy
resource "aws_autoscaling_policy" "autoscaling-policy" {
  name                   = "${var.project-name}-asg-policy"
  autoscaling_group_name = aws_autoscaling_group.ecs-autoscaling-group.name
  # adjustment_type           = "ChangeInCapacity"
  policy_type               = "TargetTrackingScaling"
  estimated_instance_warmup = "120"
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 40
  }
}


# create ECS cluster
resource "aws_ecs_cluster" "ecs-cluster" {
  name = "${var.project-name}-ecs-cluster"
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}


locals {

  mount_points = length(var.mount_points) > 0 ? [
    for mount_point in var.mount_points : {
      containerPath = lookup(mount_point, "containerPath")
      sourceVolume  = lookup(mount_point, "sourceVolume")
      readOnly      = tobool(lookup(mount_point, "readOnly", false))
    }
  ] : var.mount_points

  container_definition = {
    name                   = var.container_name
    image                  = var.container_image
    essential              = var.essential
    readonlyRootFilesystem = var.readonly_root_filesystem
    secrets                = var.secrets
    mountPoints            = local.mount_points
    portMappings           = var.port_mappings
    memory                 = var.container_memory
    cpu                    = var.container_cpu
  }

  container_definition_without_null = {
    for k, v in local.container_definition :
    k => v
    if v != null
  }
  json_map = jsonencode(merge(local.container_definition_without_null, var.container_definition))
}

# ECS Task definition
resource "aws_ecs_task_definition" "this" {
  family                = "${var.project-name}-task-definition"
  container_definitions = jsonencode([local.container_definition_without_null])
  memory                = var.container_memory
  execution_role_arn    = aws_iam_role.ecs-instance-role.arn

  volume {
    name = var.volume_name

    efs_volume_configuration {
      file_system_id          = lookup(var.efs_volume_configuration, "file_system_id", null)
      root_directory          = lookup(var.efs_volume_configuration, "root_directory", null)
      transit_encryption      = lookup(var.efs_volume_configuration, "transit_encryption", null)
      transit_encryption_port = lookup(var.efs_volume_configuration, "transit_encryption_port", null)
    }
  }

  tags = merge(var.common_tags, {
    Name = "${var.project-name}-ecs-task-definition"
  })
}

# ECS service
resource "aws_ecs_service" "this" {
  name                               = "${var.project-name}-ecs_service"
  cluster                            = aws_ecs_cluster.ecs-cluster.id
  task_definition                    = aws_ecs_task_definition.this.arn
  desired_count                      = var.desired_count
  iam_role                           = data.aws_iam_role.ecs.arn
  depends_on                         = [aws_iam_role_policy.this]
  deployment_minimum_healthy_percent = 60

  # deployment_controller {
  #   type = "CODE_DEPLOY"
  # }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = var.container_name
    container_port   = var.container_port
  }
  # network_configuration {
  #   security_groups = [aws_security_group.this.id]
  #   subnets         = [var.subnet-public-1, var.subnet-public-2]
  # }
  tags = merge(var.common_tags, {
    Name = "${var.project-name}-ecs_service"
  })

  lifecycle {
    ignore_changes = [
      task_definition
    ]
  }
}

resource "aws_cloudwatch_log_group" "log" {
  name              = "/ecs/${var.project-name}"
  # retention_in_days = 30
}

resource "aws_appautoscaling_target" "main" {
  max_capacity       = 4
  min_capacity       = 2
  resource_id        = "service/${aws_ecs_cluster.ecs-cluster.name}/${aws_ecs_service.this.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "cpu_high" {
  name               = "${var.project-name}-scale_out-cpu_utilization"
  resource_id        = "service/${aws_ecs_cluster.ecs-cluster.name}/${aws_ecs_service.this.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = var.autoscale_cooldown
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_lower_bound = var.scale_out_step_adjustment["metric_interval_lower_bound"]
      scaling_adjustment          = var.scale_out_step_adjustment["scaling_adjustment"]
    }
  }

  depends_on = [aws_appautoscaling_target.main]
}

resource "aws_appautoscaling_policy" "cpu_low" {
  name               = "${var.project-name}-scale_in-cpu_utilization"
  resource_id        = "service/${aws_ecs_cluster.ecs-cluster.name}/${aws_ecs_service.this.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = var.autoscale_cooldown
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_upper_bound = var.scale_in_step_adjustment["metric_interval_upper_bound"]
      scaling_adjustment          = var.scale_in_step_adjustment["scaling_adjustment"]
    }
  }

  depends_on = [aws_appautoscaling_target.main]
}