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
  security_groups = [aws_security_group.efs_sg.id]
}

#Create Security Group to allow access
resource "aws_security_group" "efs_sg" {
  description = "allows access to the EFS"

  vpc_id = var.vpc.id
  name   = "efs-sg"

  ingress {
    protocol = "-1"
    from_port = 0
    to_port   = 0
    cidr_blocks = ["0.0.0.0/0"]
    # TODO: fix the security
    # from_port       = 2049
    # to_port         = 2049
    # security_groups = [var.ecs_sg_id]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    # TODO: fix the security
    # cidr_blocks = [var.cidr_block]
  }
}

#Create Access Point
resource "aws_efs_access_point" "wordpress" {
  file_system_id = aws_efs_file_system.efs_file.id
  root_directory {
    path = "/wordpress"
  }
}
