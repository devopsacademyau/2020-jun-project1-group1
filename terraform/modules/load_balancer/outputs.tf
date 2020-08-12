output "target_group_arn" {
  description = "the target group arn linked of the load balancer's listener"
  value       = aws_lb_target_group.this.arn
}

output "target_group_name" {
  value = aws_lb_target_group.this.name
}

output "target_group_test_name" {
  value = aws_lb_target_group.test.name
}

output "target_group_test_arn" {
  value = aws_lb_target_group.test.arn
}

output "load_balancer" {
  description = "the details of the load balancer created { arn, arn_suffix, dns_name, zone_id }"
  value = {
    arn        = aws_lb.this.arn
    arn_suffix = aws_lb.this.arn_suffix
    dns_name   = aws_lb.this.dns_name
    zone_id    = aws_lb.this.zone_id
  }
}

output "listener_arn" {
  value = aws_lb_listener.this.arn
}

# output "listener_test_arn" {
#   value = aws_lb_listener.test.arn
# }