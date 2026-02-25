terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# 1. ECR Module
module "ecr" {
  source          = "./modules/ecr"
  resource_prefix = var.resource_prefix
}

# 2. Networking Module
module "networking" {
  source          = "./modules/networking"
  vpc_id          = var.vpc_id
  public_subnets  = var.public_subnets
  resource_prefix = var.resource_prefix
}

# 3. ECS Module
# Note: We move ECS above RDS so we can get its Security Group ID
module "ecs" {
  source              = "./modules/ecs"
  vpc_id              = var.vpc_id
  private_subnets     = var.private_subnets
  resource_prefix     = var.resource_prefix
  execution_role_arn  = var.execution_role_arn
  ecr_repository_url  = module.ecr.repository_url
  alb_sg_id           = module.networking.alb_sg_id
  blue_tg_arn         = module.networking.blue_tg_arn
  
  # Temporary database values until RDS is created
  db_host             = module.rds.db_host
  db_username         = "strapi"
  db_password         = var.db_password
}

# 4. RDS Module
module "rds" {
  source          = "./modules/rds"
  vpc_id          = var.vpc_id
  private_subnets = var.private_subnets
  resource_prefix = var.resource_prefix
  db_password     = var.db_password
  
  # Passing the ECS SG ID from the ECS module output
  ecs_sg_id       = module.ecs.ecs_sg_id
}

# 5. CodeDeploy Module
module "codedeploy" {
  source                  = "./modules/codedeploy"
  resource_prefix         = var.resource_prefix
  codedeploy_role_arn     = var.codedeploy_role_arn
  ecs_cluster_name        = module.ecs.cluster_name
  ecs_service_name        = module.ecs.service_name
  alb_listener_arn        = module.networking.listener_arn
  blue_target_group_name  = module.networking.blue_tg_name
  green_target_group_name = module.networking.green_tg_name
}