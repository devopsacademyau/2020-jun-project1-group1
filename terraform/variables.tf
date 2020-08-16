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

variable "container_definition" {
  description = "Container definition overrides which allows for extra keys or overriding existing keys."
  type        = map
  default     = {}
}

variable "port_mappings" {
  description = "The port mappings to configure for the container. This is a list of maps. Each map should contain \"containerPort\", \"hostPort\", and \"protocol\", where \"protocol\" is one of \"tcp\" or \"udp\". If using containers in a task with the awsvpc or host network mode, the hostPort can either be left blank or set to the same value as the containerPort"

  type = list(object({
    containerPort = number
    hostPort      = number
    protocol      = string
  }))

  default = []
}

variable "mount_points" {
  type = list

  description = "Container mount points. This is a list of maps, where each map should contain a `containerPath` and `sourceVolume`. The `readOnly` key is optional."
  default     = []
}

variable "instance_keypair" {
  type    = string
  default = null
}

variable "repository_name" {
  type    = string
  default = "devops-wordpress"
}