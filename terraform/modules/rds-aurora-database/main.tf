// setting the provider
provider "aws" {
  version = "~> 2.0"
  region  = "ap-southeast-2"
}


// defining custom vpc
// TODO: utilize the project's main VPC
resource "aws_vpc" "temp_custom_vpc" {
  cidr_block = "192.168.0.0/16"
  tags = {
    "Name" = "Terraform - temp_custom_vpc"
  }
}

//defining custom subnet
// TODO: utilize the project's subnetsh
resource "aws_subnet" "temp_da_rds_subnet" {
  vpc_id     = aws_vpc.temp_custom_vpc.id
  cidr_block = "192.168.51.0/24"
  availability_zone = "ap-southeast-2a"

  tags = {
    Name = "Terraform - temp_da_rds_subnet"
  }
}

resource "aws_subnet" "temp_da_rds_subnet2" {
  vpc_id     = aws_vpc.temp_custom_vpc.id
  cidr_block = "192.168.52.0/24"
  availability_zone = "ap-southeast-2b"

  tags = {
    Name = "Terraform - temp_da_rds_subnet2"
  }
}

//defining custom subnet for the database
resource "aws_db_subnet_group" "da_db_subnet_group" {
  name       = "aws_db_subnet_group_da_sb_subnet"
  subnet_ids = [aws_subnet.temp_da_rds_subnet.id, aws_subnet.temp_da_rds_subnet2.id]

  tags = {
    Name = "Terraform - My DB subnet group"
  }
}

//defining security group
// TODO: update rules accordingly
resource "aws_security_group" "da_rds_security_group" {
  name        = "access to mysql"
  description = "Allow inbound traffic on port 3306"
  vpc_id      = aws_vpc.temp_custom_vpc.id

  ingress {
    description = "Aurora mysql Inbound"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.temp_custom_vpc.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" = "Terraform security group"
  }

}


// defining aurora
// TODO: implement random passwords with SSM
resource "aws_rds_cluster" "da-aurora-cluster" {
  cluster_identifier      = "da-aurora-cluster"
  engine                  = "aurora-mysql"
  engine_version          = "5.7.mysql_aurora.2.07.1"
  engine_mode             = "serverless"
  # availability_zones      = ["ap-southeast-2"]
  database_name           = "mydb"
  master_username         = "testuser"
  master_password         = "test-password"
  backup_retention_period = 1
  vpc_security_group_ids  = [aws_security_group.da_rds_security_group.id]
  db_subnet_group_name    = aws_db_subnet_group.da_db_subnet_group.name
  skip_final_snapshot     = true

  // determining the min and max capacity for auto scalling 
  scaling_configuration {
    min_capacity = 1
    max_capacity = 2
  }
}