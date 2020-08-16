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
resource "aws_security_group" "this" {
  name        = "${var.project} access to mysql"
  description = "Allow inbound traffic on port 3306"
  vpc_id      = var.vpc.id

  ingress {
    description = "Aurora mysql Inbound"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [
      var.ecs_security_group
    ]
  }

  tags = {
    "Name" = "${var.project}-aurora-db-sg"
  }

}


// defining aurora
// TODO: implement random passwords with SSM
resource "aws_rds_cluster" "da-aurora-cluster" {
  cluster_identifier = "da-aurora-cluster"
  engine             = "aurora-mysql"
  engine_version     = "5.7.mysql_aurora.2.07.1"
  engine_mode        = "serverless"
  # availability_zones      = ["ap-southeast-2"]
  database_name           = aws_ssm_parameter.db_name.value     #"mydb"
  master_username         = aws_ssm_parameter.db_user.value     #"testuser"
  master_password         = aws_ssm_parameter.db_password.value #"test-password"
  backup_retention_period = 1
  vpc_security_group_ids  = [aws_security_group.this.id]
  db_subnet_group_name    = aws_db_subnet_group.da_db_subnet_group.name
  skip_final_snapshot     = true

  // determining the min and max capacity for auto scalling 
  scaling_configuration {
    min_capacity = 1
    max_capacity = 2
  }
}

#SSM Parameters
resource "aws_ssm_parameter" "db_host" {
  name        = "WORDPRESS_DB_HOST"
  description = "Database Host Paramater"
  type        = "SecureString"
  value       = aws_rds_cluster.da-aurora-cluster.endpoint
  overwrite   = true
}

resource "aws_ssm_parameter" "db_name" {
  name        = "WORDPRESS_DB_NAME"
  description = "Database Name Paramater"
  type        = "SecureString"
  value       = var.db_name
  overwrite   = false

  lifecycle {
    ignore_changes = [
      value
    ]
  }
}

resource "aws_ssm_parameter" "db_user" {
  name        = "WORDPRESS_DB_USER"
  description = "Database User Paramater"
  type        = "SecureString"
  value       = var.db_user
  overwrite   = false

  lifecycle {
    ignore_changes = [
      value
    ]
  }
}

resource "aws_ssm_parameter" "db_password" {
  name        = "WORDPRESS_DB_PASSWORD"
  description = "Database Password Paramater"
  type        = "SecureString"
  value       = random_password.db_password.result
  overwrite   = false

  lifecycle {
    ignore_changes = [
      value
    ]
  }
}
resource "random_password" "db_password" {
  length           = 8
  special          = true
  override_special = "!#*"
}