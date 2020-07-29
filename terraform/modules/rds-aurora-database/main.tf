//defining custom subnet for the database
resource "aws_db_subnet_group" "da_db_subnet_group" {
  name       = "${var.project}-db-subnet-group"
  subnet_ids = var.private_subnets

  tags = {
    Name = "${var.project}-DB subnet group"
  }
}

//defining security group
// TODO: update rules accordingly
resource "aws_security_group" "da_rds_security_group" {
  name        = "${var.project} access to mysql"
  description = "Allow inbound traffic on port 3306"
  vpc_id      = var.vpc.id

  ingress {
    description = "Aurora mysql Inbound"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [var.vpc.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" = "${var.project}-aurora-db-sg"
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