#variable declaration
variable "project-name" {
  type = string
}

variable "vpcCIDR" {
  description = "VPC network"
  default     = "192.168.0.0/16"
}

variable "instanceTenancy" {
  type        = list(string)
  description = "defult or dedicated"
  default     = ["default", "dedicated"]
}

variable "dnsSupport" {
  type    = bool
  default = true

}

variable "dnsHostNames" {
  type    = bool
  default = true
}

variable "map_public_ip1" {
  type    = bool
  default = true
}

variable "map_public_ip2" {
  type    = bool
  default = true
}

variable "deploy_nat" {
  type    = bool
  default = true
}