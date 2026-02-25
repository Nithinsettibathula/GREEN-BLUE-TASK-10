# --- VPC ID ---
vpc_id          = "vpc-0f3178e30a512ece3"

# --- NEW Unique Prefix ---
# Moving to v3 ensures GitHub Actions creates brand-new resources
resource_prefix = "nithin-strapi-gb-v3"

# --- Subnet IDs ---
public_subnets  = [
  "subnet-0b43fbcae615a178d", 
  "subnet-01f55437435aa1916"
]

private_subnets = [
  "subnet-0e2fee514e799df91", 
  "subnet-03e72fe79cc870da9"
]

# --- IAM Role ARNs ---
execution_role_arn  = "arn:aws:iam::811738710312:role/ecs_fargate_taskRole"
codedeploy_role_arn = "arn:aws:iam::811738710312:role/codedeploy_role"

# --- Database Password ---
db_password         = "StrapiSecurePass123"