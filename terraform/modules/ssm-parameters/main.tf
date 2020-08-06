resource "aws_ssm_parameter" "db_host" {
  name        = "WORDPRESS_DB_HOST"
  description = "Database Host Paramater"
  type        = "SecureString"
  value       = "  " # This to be replaced by RDS Host Endpoint
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
  value       = var.db_password
  overwrite   = false

  lifecycle {
    ignore_changes = [
      value
    ]
  }
}