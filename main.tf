# --- Networking Module ---
module "networking" {
  source          = "./modules/networking"
  resource_prefix = var.resource_prefix
  vpc_id          = var.vpc_id
  public_subnets  = var.public_subnets
  # Passing the required private subnets argument
  private_subnets = var.private_subnets 
}

# --- ECR Module ---
module "ecr" {
  source          = "./modules/ecr"
  resource_prefix = var.resource_prefix
}

# --- RDS Module ---
module "rds" {
  source          = "./modules/rds"
  resource_prefix = var.resource_prefix
  vpc_id          = var.vpc_id
  private_subnets = var.private_subnets
  db_password     = var.db_password
}

# --- ECS Module ---
module "ecs" {
  source             = "./modules/ecs"
  resource_prefix    = var.resource_prefix
  vpc_id             = var.vpc_id
  # Ensuring ECS has access to both subnet types for routing
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

# --- CodeDeploy Module ---
module "codedeploy" {
  source              = "./modules/codedeploy"
  resource_prefix     = var.resource_prefix
  codedeploy_role_arn = var.codedeploy_role_arn
  ecs_cluster_name    = module.ecs.cluster_name
  ecs_service_name    = module.ecs.service_name
  alb_listener_arn    = module.networking.listener_arn
  blue_tg_name        = module.networking.blue_tg_name
  green_tg_name       = module.networking.green_tg_name
}