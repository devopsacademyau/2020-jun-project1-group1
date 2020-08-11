output "rds_secrets" {
  value = {
    db_host = {
      arn = aws_ssm_parameter.db_host.arn
      name = aws_ssm_parameter.db_host.name
    }
    db_name = {
      arn = aws_ssm_parameter.db_name.arn
      name = aws_ssm_parameter.db_name.name
    }
    db_user = {
      arn = aws_ssm_parameter.db_user.arn
      name = aws_ssm_parameter.db_user.name
    }
    db_password = {
      arn = aws_ssm_parameter.db_password.arn
      name = aws_ssm_parameter.db_password.name
    }
  }
}