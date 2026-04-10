variable "prefix" {
  description = "Prefix for all IAM resources"
  type        = string
  default     = "eks"
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "create_fargate_role" {
  description = "Whether to create a role for Fargate profiles"
  type        = bool
  default     = false
}