resource "aws_efs_file_system" "efs_file" {
  creation_token = "my-efs"

  tags = {
    Name = "wordpress"
  }
}

resource "aws_efs_mount_target" "alpha" {

  count = length(var.subnet_ids)

  file_system_id = "${aws_efs_file_system.foo.id}"
  subnet_id      = var.subnet_ids[count.index]
}

resource "aws_vpc" "foo" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "alpha" {
  vpc_id            = "${aws_vpc.foo.id}"
  availability_zone = "us-west-2a"
  cidr_block        = "10.0.1.0/24"
}

resource "aws_security_group" "efs_sg" {
  description = "allows access to the EFS"

  vpc_id = var.vpc_id
  name   = "efs-sg"

  ingress {
    protocol        = "tcp"
    from_port       = 2049
    to_port         = 2049
    security_groups = [var.efs_sg.sg_id]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = [var.cidr_vpc]
  }
}