output "target_group_arn" {
  description = "the target group arn linked of the load balancer's listener"
  value       = aws_lb_target_group.this.arn
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

output "http_alb_listener_arn" {
  value       = aws_lb_listener.this.arn
  description = "The ARN of the HTTP listener (matches id)"
}

output "alb_target_group_name" {
  value       = aws_lb_target_group.this.name
  description = "The name of the Target Group."
}

output "lb_security_group" {
  value = aws_security_group.allow_web.id
}

# output "alb_group_green_name" {
#   value       = aws_lb_target_group.green.name
#   description = "The name of the Target Group Green."
# }