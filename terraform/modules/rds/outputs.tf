output "secrets" {
  value = {
    db_host = {
      name = aws_ssm_parameter.db_host.name
      arn  = aws_ssm_parameter.db_host.arn
    }
    db_name = {
      name = aws_ssm_parameter.db_name.name
      arn  = aws_ssm_parameter.db_name.arn
    }
    db_user = {
      name = aws_ssm_parameter.db_user.name
      arn  = aws_ssm_parameter.db_user.arn
    }
    db_password = {
      name = aws_ssm_parameter.db_password.name
      arn  = aws_ssm_parameter.db_password.arn
    }
  }
}
output "cluster_identifier"{
    value = aws_rds_cluster.da-aurora-cluster.cluster_identifier
    description = "RDS cluster ID"
  }
output "security_group" {
  value = aws_security_group.this.id
}