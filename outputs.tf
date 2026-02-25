output "alb_dns_name" {
  description = "The URL of the Strapi application"
  value       = module.networking.alb_dns_name
}

output "database_endpoint" {
  description = "The connection endpoint for the PostgreSQL database"
  # SYNCED: Matches the output name in modules/rds/outputs.tf
  value       = module.rds.db_instance_endpoint 
}

output "ecr_repository_url" {
  description = "The URL of the ECR repository"
  value       = module.ecr.repository_url
}

output "ecs_cluster_name" {
  description = "The name of the ECS cluster"
  value       = module.ecs.cluster_name
}