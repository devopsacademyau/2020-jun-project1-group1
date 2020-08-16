variable "project_name" {
  type = string
}

variable "vpc" {
  description = "VPC for the EFS"
  type = object({
    id                  = string
    private_subnets_ids = list(string)

  })
}
variable "cidr_block" {
  description = "cidr_block for the EFS"
  type        = string
}

variable "ecs_sg_id" {
  description = "Securtity-Group ECS ID"
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