# data "aws_ami" "this" {
#     most_recent = true
#     owners = ["amazon"]
#     filter {
#         name = "name"
#         values = ["amzn2-ami-hvm*"]
#     }
# }

resource "aws_launch_template" "devops" {
  name_prefix   = "devops"
  image_id      = "ami-0a7c4f7f17d3eecbc"
  instance_type = "t2.micro"
  key_name      = var.key_pair

  iam_instance_profile {
    arn = "arn:aws:iam::097922957316:instance-profile/ec2-ecs-role"
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.allow_internet.id]
  }

  tag_specifications {
    resource_type = "instance"
    tags = merge(var.common_tags, {
      Name = "${var.devops_class}-instance"
    })
  }

  user_data = base64encode(<<EOF
#! /bin/bash
yum update -y
echo ECS_CLUSTER=${aws_ecs_cluster.nginx.name} >> /etc/ecs/ecs.config;echo ECS_BACKEND_HOST= >> /etc/ecs/ecs.config;
    EOF
  )

  #   user_data = base64encode(<<EOF
  # #! /bin/bash
  # yum update -y
  # yum install -y httpd
  # curl 169.254.169.254/latest/meta-data/hostname > index.html
  # mv index.html /var/www/html/
  # systemctl start httpd
  #     EOF
  #   )
}
