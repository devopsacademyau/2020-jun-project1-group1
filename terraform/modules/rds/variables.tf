variable "project" {
  description = "the project name to add as preffix for some resources"
  type        = string
  default     = "devops-wordpress"
}

variable "vpc" {
  description = "the vpc id for the aurora database"
  type = object({
    id         = string
    cidr_block = string
  })
}
variable "private_subnets" {
  description = "the list of subnets / availability zones for the rds database"
  type        = list(string)
}

# SSM Paremeter Variables
variable "db_name" {
  type        = string
  description = "Database name"
  default     = "WordpressDB"
}

variable "db_user" {
  type        = string
  description = "Database Useraname"
  default     = "testuser"
}

variable "db_password" {
  type        = string
  description = "Database Password"
  default     = "  "
}

variable "ecs_security_group" {
  type = string
}