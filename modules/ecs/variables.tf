variable "resource_prefix" {}
variable "vpc_id" {}
variable "private_subnets" { type = list(string) }
variable "execution_role_arn" {}
variable "alb_sg_id" {}
variable "blue_tg_arn" {}
variable "db_host" {}
variable "db_username" {}
variable "db_password" {}
variable "ecr_repository_url" {} # Ensure this is here!