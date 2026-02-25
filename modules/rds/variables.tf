variable "resource_prefix" {}
variable "vpc_id" {}
variable "private_subnets" { type = list(string) }
variable "db_password" {}
variable "ecs_sg_id" {}