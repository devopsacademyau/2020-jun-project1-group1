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

variable "image_id" {
    type = string
    default     = "ami-0b781a9543e01e880"
}

variable "instance_type" {
    type = string
    default     = "t2.micro"
}

variable "vpc_id" {}
variable "target_group_arn" {}
variable "subnet-public-1" {}
variable "subnet-public-2" {}
