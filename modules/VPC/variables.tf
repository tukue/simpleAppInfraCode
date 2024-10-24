# modules/vpc/variables.tf
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "subnet_1_cidr" {
  description = "CIDR block for Subnet 1 in eu-north-1c"
  type        = string
}

variable "subnet_2_cidr" {
  description = "CIDR block for Subnet 2 in eu-north-1b"
  type        = string
}
