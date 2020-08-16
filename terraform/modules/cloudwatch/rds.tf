resource "aws_cloudwatch_metric_alarm" "rds" {
  alarm_name          = "${var.project}_rds_usage"
  alarm_description   = "Alerts for monitor RDS CPU, to check if usage is high"
  namespace           = "AWS/RDS"
  metric_name         = "CPUUtilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  statistic           = "Average"
  evaluation_periods  = 1
  datapoints_to_alarm = 1
  period              = 60
  threshold           = 70
  treat_missing_data  = "breaching"

  alarm_actions = [aws_sns_topic.alerts.arn]

  dimensions = {
    DBClusterIdentifier = var.rds_cluster_id
  }
}