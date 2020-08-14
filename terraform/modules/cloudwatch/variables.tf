variable "project" {
  type = string
}

variable "rds_cluster_id" {
  type = string
  description = "RDS cluster to monitor"
}

variable "alb_arn_suffix" {
  type = string
  description = "Load Balancer to monitor"
}

variable "autoscale_cooldown" {
  description = "Period watching scale (seconds)"
  default     = 300
}

variable "scale_out_evaluation_periods" {
  description = "Number of evaluation periods to scale out"
  default     = 1
}

variable "scale_out_thresholds" {
  description = "Values against which the specified statistic is compared for scale_out"
  type        = map(string)
  default     = {
    cpu = 80
  }
}

variable "scale_out_ok_actions" {
  description = "For scale-out as same as ok actions for cloudwatch alarms"
  type        = list(string)
  default     = []
}

variable "scale_out_more_alarm_actions" {
  description = "For scale-out as same as alarm actions for cloudwatch alarms"
  type        = list(string)
  default     = []
}

variable "scale_in_thresholds" {
  description = "The values against which the specified statistic is compared for scale_in"
  type        = map(string)
  default     = {
    cpu = 3
  }
}

variable "scale_in_evaluation_periods" {
  description = "The number of evaluation periods to scale in"
  default     = 2
}

variable "scale_in_ok_actions" {
  description = "For scale-in as same as ok actions for cloudwatch alarms"
  type        = list(string)
  default     = []
}

variable "scale_in_more_alarm_actions" {
  description = "For scale-in as same as alarm actions for cloudwatch alarms"
  type        = list(string)
  default     = []
}

variable "ecs_cluster_name" {
  type = string
}

variable "ecs_service_name" {
  type = string
}

variable "policy_cpu_low" {
  type = string
}

variable "policy_cpu_high" {
  type = string
}