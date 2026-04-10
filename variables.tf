variable "region" {
  description = "AWS region"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "subnet_1_cidr" {
  description = "CIDR block for Subnet 1"
  type        = string
}

variable "subnet_2_cidr" {
  description = "CIDR block for Subnet 2"
  type        = string
}

variable "eks_role_name" {
  description = "Name of the EKS IAM role"
  type        = string
}

variable "eks_sg_name" {
  description = "Name of the EKS security group"
  type        = string
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "node_role_name" {
  description = "Name of the node group IAM role"
  type        = string
}

variable "node_group_name" {
  description = "Name of the node group"
  type        = string
}

variable "desired_size" {
  description = "Desired number of worker nodes"
  type        = number
}

variable "min_size" {
  description = "Minimum number of worker nodes"
  type        = number
}

variable "max_size" {
  description = "Maximum number of worker nodes"
  type        = number
}

variable "enable_ansible" {
  description = "Flag to enable or disable Ansible configuration"
  type        = bool
  default     = false
}