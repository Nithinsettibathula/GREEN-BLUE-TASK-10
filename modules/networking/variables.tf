variable "vpc_id" {
  type = string
}

variable "public_subnets" {
  type = list(string)
}

variable "resource_prefix" {
  type = string
}