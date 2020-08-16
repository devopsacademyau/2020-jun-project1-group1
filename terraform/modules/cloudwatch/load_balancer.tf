
resource "aws_sns_topic" "alerts" {
  name = "alerts"
}
resource "aws_cloudwatch_metric_alarm" "alb" {
  alarm_name                = "${var.project}_loadbalancer_response-time"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = 1
  metric_name               = "TargetResponseTime"
  namespace                 = "AWS/ApplicationELB"
  period                    = "300"
  statistic                 = "Average"
  threshold                 = "3"
  alarm_description         = "Alert to check  if response time is high"
  insufficient_data_actions = []
  alarm_actions             = [aws_sns_topic.alerts.arn]
  datapoints_to_alarm       = 1
  dimensions = {
    LoadBalancer = var.alb_arn_suffix
  }
}