variable "aws_region" {
  type    = string
  default = "ap-southeast-2"
}

variable "project" {
  description = "the name of the project"
  type        = string
}

variable "vpcCIDR" {
  description = "VPC network"
  type        = string
  default     = "192.168.0.0/16"
}

variable "deploy_nat" {
  description = "if true, the Network Gateway will be deployed for private subnets"
  type        = bool
  default     = true
}

variable "https_enabled" {
  description = "enable/disable https (port 443) in the load balancer's security group"
  type        = bool
  default     = true
}