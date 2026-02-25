variable "vpc_id" {
  type = string
}

variable "private_subnets" {
  type = list(string)
}

variable "resource_prefix" {
  type = string
}

variable "ecs_sg_id" {
  description = "Security group ID of the ECS tasks to allow DB access"
  type        = string
}

variable "db_password" {
  description = "Master password for RDS"
  type        = string
  sensitive   = true
}