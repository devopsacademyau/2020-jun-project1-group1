variable "aws_region" {
  description = "the aws region to deploy the resources"
  type        = string
  default     = "ap-southeast-2"
}

variable "devops_class" {
  description = "define the class id from devops academy"
  type        = string
}

variable "common_tags" {
  description = "define tags which will be applied for every resource created"
  type        = map(string)
  default     = {}
}

variable "vpc_id" {
  type    = string
  default = "vpc-027019faaf6756407"
}

variable "lb_subnets" {
  type = list(string)
}

variable "key_pair" {
  type    = string
  default = "kp-devops"
}