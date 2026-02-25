variable "resource_prefix" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "private_subnets" {
  type = list(string)
}

variable "db_password" {
  type = string
}

variable "ecs_sg_id" {
  type        = string
  description = "Security Group ID of the ECS tasks to allow database access"
}