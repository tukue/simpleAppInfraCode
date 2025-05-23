variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs"
  type        = list(string)
}

variable "eks_role_name" {
  description = "Name of the EKS IAM role"
  type        = string
  default     = "my-eks-role"
}

variable "eks_sg_name" {
  description = "Name of the EKS security group"
  type        = string
  default     = "my-eks-security-group"
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "my-eks-cluster"
}

variable "node_role_name" {
  description = "Name of the node group IAM role"
  type        = string
  default     = "my-node-role"
}

variable "node_group_name" {
  description = "Name of the node group"
  type        = string
  default     = "my-node-group"
}

variable "desired_size" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 3
}

variable "min_size" {
  description = "Minimum number of worker nodes"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum number of worker nodes"
  type        = number
  default     = 5
}
