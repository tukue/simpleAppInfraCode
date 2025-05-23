module "vpc" {
  source = "./modules/vpc"

  vpc_cidr     = "10.0.0.0/16"
  subnet_1_cidr = "10.0.1.0/24"
  subnet_2_cidr = "10.0.2.0/24"
}

module "eks" {
  source = "./modules/eks"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = [module.vpc.subnet_1_id, module.vpc.subnet_2_id]

  cluster_name    = "my-eks-cluster"
  node_group_name = "my-node-group"
}


