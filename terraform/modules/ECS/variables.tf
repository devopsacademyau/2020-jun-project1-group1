#variable declaration
variable "project-name" {
  type = string
}

variable "max-size" {
  description = "Maximum number of instances in the cluster"
  type        = number
  default     = 5
}
variable "min-size" {
  description = "Minimum number of instances in the cluster"
  type        = number
  default     = 2
}

variable "image_id" {
  type    = string
  default = "ami-0533a854980d7deb7"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "vpc_id" {}
variable "target_group_arn" {}

variable "private_subnets" {
  type = list(string)
}

variable "volume_name" {
  description = "The name of the volume"
  type        = string
  default     = "efs-system-file"
}

variable "efs_volume_configuration" {
  description = "Used to configure a EFS volume"
  type = object({
    file_system_id          = string
    root_directory          = string
    transit_encryption      = string
    transit_encryption_port = number
  })
}

variable "desired_count" {
  description = "The number of instances of the task definition"
  type        = number
  default     = 2
}

variable "container_port" {
  description = "The port value, already specified in the task definition, to be used for your service discovery service"
  type        = number
  default     = 80
}

variable "common_tags" {
  description = "common tags which will be merged with all resources created."
  type        = map(string)
  default = {
    devops_academy = "project1"
    deployed_by    = "terraform"
  }
}

variable "container_name" {
  description = "The name of the container. Up to 255 characters ([a-z], [A-Z], [0-9], -, _ allowed)"
  type        = string
}

variable "container_image" {
  description = "The image used to start the container. Images in the Docker Hub registry available by default"
  type        = string
}

variable "container_memory" {
  type        = number
  description = "The amount of memory (in MiB) to allow the container to use. This is a hard limit, if the container attempts to exceed the container_memory, the container is killed. This field is optional for Fargate launch type and the total amount of container_memory of all containers in a task will need to be lower than the task memory value"
  default     = 128
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

variable "container_cpu" {
  description = "The number of cpu units to reserve for the container. This is optional for tasks using Fargate launch type and the total amount of container_cpu of all containers in a task will need to be lower than the task-level cpu value"
  type        = number
  default     = 256
}

variable "essential" {
  description = "Determines whether all other containers in a task are stopped, if this container fails or stops for any reason. Due to how Terraform type casts booleans in json it is required to double quote this value"
  type        = bool
  default     = true
}

variable "readonly_root_filesystem" {
  type        = bool
  description = "Determines whether a container is given read-only access to its root filesystem. Due to how Terraform type casts booleans in json it is required to double quote this value"
  default     = false
}

variable "mount_points" {
  type = list

  description = "Container mount points. This is a list of maps, where each map should contain a `containerPath` and `sourceVolume`. The `readOnly` key is optional."
  default     = []
}

variable "secrets" {
  type = list(object({
    name      = string
    valueFrom = string
  }))
  description = "The secrets to pass to the container. This is a list of maps"
  default     = null
}

variable "instance_keypair" {
  type    = string
  default = null
}


variable "autoscale_cooldown"{
  description = "The cooldown"
  default     = 30
}

variable "scale_out_step_adjustment" {
  description = "The attributes of step scaling policy"
  type        = map(string)
  default     = {
    metric_interval_lower_bound = 0
    scaling_adjustment          = 1
  }
}

variable "scale_in_step_adjustment" {
  description = "The attributes of step scaling policy"
  type        = map(string)
  default     = {
    metric_interval_upper_bound = 0
    scaling_adjustment          = -1
  }
 }

variable "lb_security_group" {
  type = string
}