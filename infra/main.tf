terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.region
}

module "iam" {
  source = "./modules/iam"

  prefix = var.cluster_name
  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

module "vpc" {
  source = "./modules/vpc"

  vpc_cidr      = var.vpc_cidr
  subnet_1_cidr = var.subnet_1_cidr
  subnet_2_cidr = var.subnet_2_cidr
  environment   = var.environment
  cluster_name  = var.cluster_name
}

module "eks" {
  source = "./modules/eks"

  vpc_id           = module.vpc.vpc_id
  subnet_ids       = module.vpc.subnet_ids
  cluster_name     = var.cluster_name
  node_group_name  = var.node_group_name
  cluster_role_arn = module.iam.cluster_role_arn
  node_role_arn    = module.iam.node_role_arn
  desired_size     = var.desired_size
  min_size         = var.min_size
  max_size         = var.max_size
}
