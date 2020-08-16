module "vpc" {
  source       = "./modules/VPC-network"
  project-name = var.project
  vpcCIDR      = var.vpcCIDR
  deploy_nat   = var.deploy_nat
}

module "rds" {
  source  = "./modules/rds"
  project = var.project
  vpc = {
    id         = module.vpc.vpc_id
    cidr_block = var.vpcCIDR
  }
  private_subnets    = module.vpc.private_subnets[*].id
  ecs_security_group = module.ecs_cluster_wordpress.ecs-access-security-group
}

module "load_balancer" {
  source        = "./modules/load_balancer"
  project       = var.project
  vpc_id        = module.vpc.vpc_id
  lb_subnets    = module.vpc.public_subnets[*].id
  https_enabled = var.https_enabled
}

module "container_registry" {
  source          = "./modules/container_registry"
  repository_name = var.repository_name
}

module "efs" {
  source       = "./modules/efs"
  project_name = var.project
  vpc = {
    id                  = module.vpc.vpc_id
    private_subnets_ids = module.vpc.private_subnets[*].id
  }
  cidr_block = var.vpcCIDR
  ecs_sg_id  = module.ecs_cluster_wordpress.ecs-access-security-group
}

module "ecs_cluster_wordpress" {
  source            = "./modules/ECS"
  project-name      = var.project
  target_group_arn  = module.load_balancer.target_group_arn
  vpc_id            = module.vpc.vpc_id
  private_subnets   = module.vpc.private_subnets[*].id
  instance_keypair  = var.instance_keypair
  lb_security_group = module.load_balancer.lb_security_group

  container_name  = module.container_registry.ecr_repository.name
  container_image = module.container_registry.ecr_repository.repository_url
  secrets = [
    {
      name      = module.rds.secrets.db_host.name
      valueFrom = module.rds.secrets.db_host.arn
    },
    {
      name      = module.rds.secrets.db_name.name
      valueFrom = module.rds.secrets.db_name.arn
    },
    {
      name      = module.rds.secrets.db_user.name
      valueFrom = module.rds.secrets.db_user.arn
    },
    {
      name      = module.rds.secrets.db_password.name
      valueFrom = module.rds.secrets.db_password.arn
    }
  ]

  efs_volume_configuration = {
    file_system_id          = module.efs.id
    root_directory          = "/"
    transit_encryption      = "ENABLED"
    transit_encryption_port = null
  }

  port_mappings = var.port_mappings

  mount_points = var.mount_points
}

# module "code_deploy" {
#   source                     = "./modules/ecs-code-deploy"
#   project                    = var.project
#   ecs_cluster_name           = module.ecs_cluster_wordpress.ecs_name
#   ecs_service_name           = module.ecs_cluster_wordpress.ecs_service_name
#   lb_listener_arns           = [module.load_balancer.http_alb_listener_arn]
#   blue_lb_target_group_name  = module.load_balancer.alb_target_group_name
#   green_lb_target_group_name = module.load_balancer.alb_group_green_name}

#   auto_rollback_enabled            = true
#   auto_rollback_events             = ["DEPLOYMENT_FAILURE"]
#   action_on_timeout                = "STOP_DEPLOYMENT"
#   wait_time_in_minutes             = 20
#   termination_wait_time_in_minutes = 20
# }

module "cloudwatch" {
  source           = "./modules/cloudwatch"
  project          = var.project
  rds_cluster_id   = module.rds.cluster_identifier
  alb_arn_suffix   = module.load_balancer.load_balancer.arn_suffix
  ecs_cluster_name = module.ecs_cluster_wordpress.ecs_name
  ecs_service_name = module.ecs_cluster_wordpress.ecs_service_name
  policy_cpu_low   = module.ecs_cluster_wordpress.autoscaling_policy_cpu_low
  policy_cpu_high  = module.ecs_cluster_wordpress.autoscaling_policy_cpu_high
}
