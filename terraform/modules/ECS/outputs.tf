output "ecs-access-security-group" {
  value = aws_security_group.this.id
}

output "ecs_name" {
  value = aws_ecs_cluster.ecs-cluster.name
}

output "ecs_service_name" {
  value = aws_ecs_service.this.name
}

output "autoscaling_policy_cpu_low" {
  value = aws_appautoscaling_policy.cpu_low.arn
}

output "autoscaling_policy_cpu_high" {
  value = aws_appautoscaling_policy.cpu_high.arn
}