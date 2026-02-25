variable "resource_prefix" { type = string }
variable "vpc_id" { type = string }

variable "public_subnets" {
  type = list(string)
}

variable "private_subnets" {
  type = list(string)
}