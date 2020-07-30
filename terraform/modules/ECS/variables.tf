#variable declaration
variable "project-name" {
  type = string
}


variable "max-size" {
  description = "Maximum number of instances in the cluster"
  type = number
    default = 5
}
variable "min-size" {
  description = "Minimum number of instances in the cluster"
  type = number
    default = 1
}


variable "vpcCIDR" {
    description = "VPC network"
    type = string
    default     = "192.168.0.0/16"
}


variable "target_group_arn" {}
variable "subnet-public-1" {}
variable "subnet-public-2" {}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}
