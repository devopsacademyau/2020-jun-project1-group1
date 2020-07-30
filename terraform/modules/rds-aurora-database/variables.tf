variable "vpc" {
  description = "the vpc id for the aurora database"
  type        = object({
      id = string
      cidr_block = string
  })
}

variable "private_subnets" {
  description = "the list of subnets / availability zones for the rds database"
  type        = list(string)
}


variable "project" {
  description = "the project name to add as preffix for some resources"
  type        = string
  default     = "devops-wordpress"
}
