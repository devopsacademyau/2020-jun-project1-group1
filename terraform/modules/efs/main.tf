#mount File
resource "aws_efs_file_system" "efs_file" {
  creation_token   = var.project_name
  throughput_mode  = "bursting"
  performance_mode = "generalPurpose"
  encrypted        = false

  tags = {
    Name = "wordpress"
  }
}

resource "aws_efs_mount_target" "default" {

  count = length(var.vpc.private_subnets_ids)

  file_system_id  = aws_efs_file_system.efs_file.id
  subnet_id       = var.vpc.private_subnets_ids[count.index]
  security_groups = [aws_security_group.this.id]
}

#Create Security Group to allow access
resource "aws_security_group" "this" {
  description = "allows access to the EFS"

  vpc_id = var.vpc.id
  name   = "efs-sg"

  ingress {
    protocol        = "tcp"
    from_port       = 2049
    to_port         = 2049
    security_groups = [var.ecs_sg_id]
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-efs-sg"
  })
}

resource "aws_security_group_rule" "ecs_allow_efs_egress" {
  type                     = "egress"
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  security_group_id        = var.ecs_sg_id
  source_security_group_id = aws_security_group.this.id
  description              = "allow egress from ec2 instances to efs"
}

#Create Access Point
resource "aws_efs_access_point" "wordpress" {
  file_system_id = aws_efs_file_system.efs_file.id
  root_directory {
    path = "/"
  }
}
