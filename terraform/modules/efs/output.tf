output "efs_id" {
  value = aws_efs_file_system.efs_file.id
}
output "efs_dns_name" {
  value = aws_efs_file_system.efs_file.dns_name
}