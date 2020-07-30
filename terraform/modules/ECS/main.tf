provider "aws" {
  region = "ap-southeast-2"
}

#################################################
########   Security group for ECS
#################################################

#create ecs security group
resource "aws_security_group" "ecs-access-security-group" {
  name        = "ecs-access-security-group"
  vpc_id      = var.vpc_id
  ingress {
    from_port       = 0
    to_port         = 0 
    protocol        = "-1" 
    cidr_blocks     = ["0.0.0.0/0"]
 #  security_groups =  output SG from alb????
    description     = "inbound allowed only via Application load balancer"
    }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    }

  tags = {
    Name = "${var.project-name}-ecs-access-security-group"
  }
}

#################################################
########   I AM STUFF 
#################################################


resource "aws_iam_role" "ecs-instance-role" {
    name                = "ecs-instance-role"
    path                = "/"
    assume_role_policy  = <<EOF
{
"Version": "2012-10-17",
"Statement": [
  {
    "Effect": "Allow",
    "Principal": {
      "Service": "ec2.amazonaws.com"
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

resource "aws_iam_instance_profile" "ecs-instance-profile" {
    name = "ecs-instance-profile"
    role = aws_iam_role.ecs-instance-role.id
    }


#################################################
########   ECS stuff
#################################################

# create launch configuration
resource "aws_launch_configuration" "ecs-launch-configuration" {
    name                        = "${var.project-name}-ecs-launch-configuration"
    image_id                    = "ami-0b781a9543e01e880"
    instance_type               = "t2.micro"
    iam_instance_profile        = aws_iam_instance_profile.ecs-instance-profile.arn
    lifecycle {
     	create_before_destroy = true
    }
    security_groups             = [aws_security_group.ecs-access-security-group.id]
    associate_public_ip_address = "true"
    user_data                   = <<EOF
                                  #!/bin/bash
                                  echo ECS_CLUSTER=aws_ecs_cluster.ecs-cluster.name >> /etc/ecs/ecs.config
                                  EOF
}


# create auto scaling group
resource "aws_autoscaling_group" "ecs-autoscaling-group" {
    name                        	= "ecs-autoscaling-group"
    max_size                    	= var.max-size
    min_size                    	= var.min-size
    wait_for_capacity_timeout  	= 0
    vpc_zone_identifier         	= [var.subnet-public-1,var.subnet-public-2]
    launch_configuration        	= aws_launch_configuration.ecs-launch-configuration.id
    health_check_type           	= "EC2"
    target_group_arns    		= [var.target_group_arn]
    health_check_grace_period 	= 0
    default_cooldown          	= 300
    termination_policies      	= ["OldestInstance"]
      tag {
      key        			= "Name"
      value        			= "${var.project-name}-ECS"
      propagate_at_launch 		= true 
  	}
  }
  


#create auto scaling policy
resource "aws_autoscaling_policy" "autoscaling-policy" {
  name                      = "${var.project-name}-asg-policy"
  autoscaling_group_name    = aws_autoscaling_group.ecs-autoscaling-group.name
  adjustment_type           = "ChangeInCapacity"
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
}
