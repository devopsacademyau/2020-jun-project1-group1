variable "common_tags" {
  description = "common tags which will be merged with all resources created."
  type        = map(string)
  default = {
    devops_academy = "project1"
    deployed_by    = "terraform"
  }
}

variable "repository_name" {
  description = "the name of the ECR repository to be created."
  type        = string
  default     = "devops-wordpress"
}