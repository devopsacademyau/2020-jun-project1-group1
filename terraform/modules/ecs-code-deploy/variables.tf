variable "project" {
  description = "Project name"
  type        = string
}

variable "ecs_cluster_name" {
  type        = string
  description = "The ECS Cluster name."
}

variable "ecs_service_name" {
  type        = string
  description = "The ECS Service name."
}

variable "lb_listener_arns" {
  description = "List of Amazon Resource Names (ARNs) of the load balancer listeners."
  type        = list
}

variable "blue_lb_target_group_name" {
  description = "Name of the blue target group."
  type        = string
}

variable "green_lb_target_group_name" {
  description = "Name of the green target group."
  type        = string
}

variable "auto_rollback_enabled" {
  description = "Indicates whether a defined automatic rollback configuration is currently enabled for this Deployment Group."
  default     = true
  type        = string
}

variable "auto_rollback_events" {
  description = "The event type or types that trigger a rollback."
  default     = ["DEPLOYMENT_FAILURE"]
  type        = list
}

variable "action_on_timeout" {
  description = "When to reroute traffic from an original environment to a replacement environment in a blue/green deployment."
  default     = "CONTINUE_DEPLOYMENT"
  type        = string
}

variable "wait_time_in_minutes" {
  description = "The number of minutes to wait before the status of a blue/green deployment changed to Stopped if rerouting is not started manually."
  default     = 0
  type        = string
}

variable "termination_wait_time_in_minutes" {
  description = "The number of minutes to wait after a successful blue/green deployment before terminating instances from the original environment."
  default     = 5
  type        = string
}

variable "test_traffic_route_listener_arns" {
  description = "List of Amazon Resource Names (ARNs) of the load balancer to route test traffic listeners."
  default     = []
  type        = list
}

variable "iam_path" {
  description = "Path in which to create the IAM Role and the IAM Policy."
  default     = "/"
  type        = string
}

variable "description" {
  description = "The description of the all resources."
  default     = "Managed by Terraform"
  type        = string
}

variable "common_tags" {
  description = "common tags which will be merged with all resources created."
  type        = map(string)
  default = {
    devops_academy = "project1"
    deployed_by    = "terraform"
  }
}