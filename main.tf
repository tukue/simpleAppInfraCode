module "vpc" {
  source = "./modules/VPC" // Changed from vpc to VPC to match actual directory name

  vpc_cidr     = var.vpc_cidr
  subnet_1_cidr = var.subnet_1_cidr
  subnet_2_cidr = var.subnet_2_cidr
  environment = "dev"
  cluster_name = var.cluster_name
}

module "eks" {
  source = "./modules/eks"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.subnet_ids
  cluster_name = var.cluster_name
  node_group_name = var.node_group_name
  eks_role_name = var.eks_role_name
  node_role_name = var.node_role_name
  desired_size = var.desired_size
  min_size = var.min_size
  max_size = var.max_size
}


