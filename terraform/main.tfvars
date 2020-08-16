project         = "devops-wordpress"

deploy_nat    = true
https_enabled = false

port_mappings = [
  {
    hostPort      = 0
    containerPort = 80
    protocol      = "tcp"
  }
]

mount_points = [
  {
    containerPath = "/var/www/html",
    sourceVolume  = "efs-system-file"
  }
]