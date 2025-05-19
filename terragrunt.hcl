terraform {
  source = "./modules" # Path to your Terraform modules
}

inputs = {
  region         = "eu-north-1"
  vpc_cidr       = "10.0.0.0/16"
  subnet_1_cidr  = "10.0.1.0/24"
  subnet_2_cidr  = "10.0.2.0/24"
  cluster_name   = "my-eks-cluster"
  node_group_name = "my-node-group"
}

remote_state {
  backend = "s3"
  config = {
    bucket         = "my-terraform-state-eks-infra"
    key            = "simpleApp/terraform.tfstate"
    region         = "eu-north-1"
    encrypt        = true
  }
}