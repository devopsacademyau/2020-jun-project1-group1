output "vpc-module" {
  value = module.vpc
}

output "lb-module" {
  value = module.load_balancer
}

output "ecr-module" {
  value = module.container_registry
}