# --- VPC and Networking Variables ---
variable "vpc_id" {
  description = "The ID of the VPC found using AWS CLI"
  type        = string
}

variable "public_subnets" {
  description = "The list of public subnets for the ALB"
  type        = list(string)
}

variable "private_subnets" {
  description = "The list of private subnets for ECS and RDS"
  type        = list(string)
}

# --- Naming and Identity ---
variable "resource_prefix" {
  description = "Unique name prefix to avoid collisions with other interns"
  type        = string
}

# --- IAM Roles (From Team Head) ---
variable "execution_role_arn" {
  description = "ARN for the ecs_fargate_taskRole"
  type        = string
}

variable "codedeploy_role_arn" {
  description = "ARN for the codedeploy_role"
  type        = string
}

# --- Database Secrets ---
variable "db_password" {
  description = "The master password for the PostgreSQL RDS instance"
  type        = string
  sensitive   = true # This hides the password in the terminal logs
}