module "vpc" {
  source       = "./modules/VPC-network"
  project-name = var.project
  vpcCIDR      = var.vpcCIDR
  deploy_nat   = var.deploy_nat
}

module "rds" {
  source = "./modules/rds"
}

module "rds-aurora-database" {
  source  = "./modules/rds-aurora-database"
  project = var.project
  vpc = {
    id         = module.vpc.vpc_id
    cidr_block = var.vpcCIDR
  }
  private_subnets = module.vpc.private_subnets[*].id
}

module "load_balancer" {
  source        = "./modules/load_balancer"
  project       = var.project
  vpc_id        = module.vpc.vpc_id
  lb_subnets    = module.vpc.public_subnets[*].id
  https_enabled = var.https_enabled
}

module "container_registry" {
  source = "./modules/container_registry"
}

 module "EFS" {
  source = "./modules/efs"
  project_name = var.project
  vpc = {
    id                  = module.vpc.vpc_id
    private_subnets_ids = module.vpc.private_subnets[*].id
  }
  cidr_block = var.vpcCIDR
  ecs_sg_id = module.ECS_CLUSTER_MODULE.ecs-access-security-group
}

module "ECS_CLUSTER_MODULE" {
  source = "./modules/ECS"
  project-name      = var.project
  target_group_arn  = module.load_balancer.target_group_arn
  vpc_id 	     = module.vpc.vpc_id
  subnet-public-1   = module.vpc.subnet-public-1
  subnet-public-2   = module.vpc.subnet-public-2
 }

# module "ECS_SERVICE_MODULE" {
#   source = "MODULE_PATH"
# }
