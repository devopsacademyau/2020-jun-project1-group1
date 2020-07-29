variable "vpc_id" {
  description = "the vpc id for the load balancer"
  type        = string
}

variable "lb_subnets" {
  description = "the list of subnets / availability zones for the load balancer"
  type        = list(string)
}

variable "https_enabled" {
  description = "enable/disable https (port 443) in the load balancer's security group"
  type        = bool
  default     = true
}

variable "project" {
  description = "the project name to add as preffix for some resources"
  type        = string
  default     = "devops-wordpress"
}

