# --- Project Identification ---
resource_prefix = "nithin-strapi-gb-v3"

# --- Networking (VPC and Subnet IDs) ---
# Replace these with the actual IDs from your AWS Console
vpc_id          = "vpc-0f3178e30a512ece3"
public_subnets  = ["subnet-07e120895311894d0", "subnet-0726694e97669d273"] 
private_subnets = ["subnet-03178e30a512ece3", "subnet-0987654321fedcba"] 

# --- IAM Roles (Permissions) ---
# Ensure these roles have the necessary trust relationships for ECS and CodeDeploy
execution_role_arn  = "arn:aws:iam::811738710312:role/ecs_fargate_taskRole"
codedeploy_role_arn = "arn:aws:iam::811738710312:role/CodeDeployRole"

# --- Database Credentials ---
# This password will be used by Strapi to authenticate with the RDS instance
db_password = "YourSecurePassword123!"