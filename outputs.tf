# --- Networking Outputs ---
output "strapi_url" {
  description = "The public URL to access the Strapi application"
  value       = "http://${module.networking.alb_dns_name}"
}

output "alb_arn" {
  description = "The ARN of the Application Load Balancer"
  value       = module.networking.listener_arn
}

# --- ECS Outputs ---
output "ecs_cluster_name" {
  description = "The name of the created ECS Cluster"
  value       = module.ecs.cluster_name
}

output "ecs_service_name" {
  description = "The name of the ECS Fargate Service"
  value       = module.ecs.service_name
}

# --- Database Outputs ---
output "database_endpoint" {
  description = "The connection endpoint for the RDS PostgreSQL instance"
  value       = module.rds.db_host
}

# --- CodeDeploy Outputs ---
output "codedeploy_app_name" {
  description = "The name of the CodeDeploy Application"
  value       = module.codedeploy.app_name
}

output "codedeploy_deployment_group" {
  description = "The name of the CodeDeploy Deployment Group"
  value       = module.codedeploy.deployment_group_name
}

output "deployment_strategy" {
  description = "The Blue/Green deployment strategy used"
  value       = "CodeDeployDefault.ECSCanary10Percent5Minutes"
}