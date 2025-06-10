variable "allowed_cidr_block" {
  description = "The CIDR block that is allowed to access the EKS cluster"
  type        = string
  default     = "10.0.0.0/16"  # Default to VPC CIDR, should be overridden with more specific value
}

variable "vpc_id" {
  description = "The ID of the VPC where the EKS cluster will be created"
  type        = string
}

variable "subnet_ids" {
  description = "The IDs of the subnets where the EKS cluster will be created"
  type        = list(string)
}

variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
}

variable "node_group_name" {
  description = "The name of the EKS node group"
  type        = string
}

variable "eks_role_name" {
  description = "The name of the IAM role for the EKS cluster"
  type        = string
  default     = "eks-cluster-role"
}

variable "node_role_name" {
  description = "The name of the IAM role for the EKS node group"
  type        = string
  default     = "eks-node-role"
}

variable "eks_sg_name" {
  description = "The name of the security group for the EKS cluster"
  type        = string
  default     = "eks-cluster-sg"
}

variable "desired_size" {
  description = "The desired number of nodes in the EKS node group"
  type        = number
  default     = 2
}

variable "min_size" {
  description = "The minimum number of nodes in the EKS node group"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "The maximum number of nodes in the EKS node group"
  type        = number
  default     = 3
}