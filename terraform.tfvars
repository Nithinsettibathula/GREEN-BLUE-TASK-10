# --- Project Identification ---
resource_prefix = "nithin-strapi-final-v11"

# --- Networking ---
vpc_id          = "vpc-0f3178e30a512ece3"
public_subnets  = ["subnet-0b43fbcae615a178d", "subnet-01f55437435aa1916"] 
private_subnets = ["subnet-03e72fe79cc870da9", "subnet-0e2fee514e799df91"] 

# --- IAM Roles ---
execution_role_arn  = "arn:aws:iam::811738710312:role/ecs_fargate_taskRole"
codedeploy_role_arn = "arn:aws:iam::811738710312:role/codedeploy_role"

# --- Database ---
db_password = "YourSecurePassword123!"