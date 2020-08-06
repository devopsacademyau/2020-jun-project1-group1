project       = "devops-wordpress"
deploy_nat    = false
https_enabled = false

port_mappings = [
  {
    hostPort      = 80
    containerPort = 80
    protocol      = "tcp"
  }
]

mount_points = [
  {
    containerPath = "/var/www/html",
    sourceVolume  = "da-efs-storage"
  }
]