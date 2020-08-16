resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "${var.project}-ECSService-CPUUsage-High"
  alarm_description   = "Alert scale-out pushed by cpu usage"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = var.scale_out_evaluation_periods
  metric_name         = "CPUUtilization"
  namespace           = "ECS"
  period              = var.autoscale_cooldown
  statistic           = "Average"
  threshold           = var.scale_out_thresholds["cpu"]
  treat_missing_data  = "notBreaching"
  ok_actions          = compact(var.scale_out_ok_actions)
  alarm_actions       = compact(
    concat(
      [var.policy_cpu_high], 
      var.scale_out_more_alarm_actions,
    ),
  )

  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = var.ecs_service_name
  }
}

resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  alarm_name          = "${var.project}-ECSService-CPUUsage-Low"
  alarm_description   = "${var.project} scale-in pushed by cpu-utilization"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = var.scale_in_evaluation_periods
  metric_name         = "CPUUtilization"
  namespace           = "ECS"
  period              = var.autoscale_cooldown
  statistic           = "Average"
  threshold           = var.scale_in_thresholds["cpu"]
  treat_missing_data  = "notBreaching"
  ok_actions          = compact(var.scale_in_ok_actions)
  alarm_actions       = compact(
    concat(
      [var.policy_cpu_low], 
      var.scale_in_more_alarm_actions,
    ),
  )

  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = var.ecs_service_name
  }
}