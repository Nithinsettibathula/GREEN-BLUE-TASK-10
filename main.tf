# --- 1. Networking Module ---
# Creates the VPC Endpoints (for ECR/S3), ALB, and Target Groups
module "networking" {
  source          = "./modules/networking"
  resource_prefix = var.resource_prefix
  vpc_id          = var.vpc_id
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
}

# --- 2. ECR Module ---
# Creates the repository for your Strapi Docker images
module "ecr" {
  source          = "./modules/ecr"
  resource_prefix = var.resource_prefix
}

# --- 3. RDS Module ---
# Sets up the PostgreSQL database in private subnets
module "rds" {
  source          = "./modules/rds"
  resource_prefix = var.resource_prefix
  vpc_id          = var.vpc_id
  private_subnets = var.private_subnets
  db_password     = var.db_password
}

# --- 4. ECS Module ---
# Deploys the Fargate cluster and service with your Strapi container
module "ecs" {
  source             = "./modules/ecs"
  resource_prefix    = var.resource_prefix
  vpc_id             = var.vpc_id
  public_subnets     = var.public_subnets
  private_subnets    = var.private_subnets
  execution_role_arn = var.execution_role_arn
  alb_sg_id          = module.networking.alb_sg_id
  blue_tg_arn        = module.networking.blue_tg_arn
  db_host            = module.rds.db_instance_endpoint
  db_username        = "postgres"
  db_password        = var.db_password
  ecr_repository_url = module.ecr.repository_url
}

# --- 5. CodeDeploy Module ---
# Manages the Blue/Green traffic shifting
module "codedeploy" {
  source              = "./modules/codedeploy"
  resource_prefix     = var.resource_prefix
  codedeploy_role_arn = var.codedeploy_role_arn
  ecs_cluster_name    = module.ecs.cluster_name
  ecs_service_name    = module.ecs.service_name
  alb_listener_arn    = module.networking.listener_arn
  
  # Names must match the variables in modules/codedeploy/variables.tf
  blue_target_group_name  = module.networking.blue_tg_name
  green_target_group_name = module.networking.green_tg_name
}