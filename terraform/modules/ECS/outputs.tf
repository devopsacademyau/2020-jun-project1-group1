output "ecs-access-security-group" {
  value = aws_security_group.this.id
}

output "ecs_name" {
  value = aws_ecs_cluster.ecs-cluster.name
}

output "ecs_service_name" {
  value = aws_ecs_service.this.name
}