# Create an EKS cluster
resource "aws_eks_cluster" "my_eks_cluster" {
    name     = "my-eks-cluster"
    role_arn = module.iam.aws_iam_role.my_eks_role.arn
    
    vpc_config {
        subnet_ids = [module.vpc.aws_subnet.my_subnet.id, module.vpc.aws_subnet.myd_subnet_2.id]
        security_group_ids = [module.security_group.my_security_group.id]
    }
}

# Create a node group
resource "aws_eks_node_group" "my_node_group" {
    cluster_name    = aws_eks_cluster.my_eks_cluster.name
    node_group_name = "my-node-group"
    node_role_arn   = module.iam.aws_iam_role.my_node_role.arn
    subnet_ids      = [module.vpc.aws_subnet.my_subnet.id, module.vpc.aws_subnet.my_subnet_2.id]
   
    
    scaling_config {
        desired_size = 3
        min_size     = 1
        max_size     = 5
    }
  
} 

# Create a node group
resource "aws_eks_node_group" "my_node_group" {
    cluster_name    = aws_eks_cluster.my_eks_cluster.name
    node_group_name = "my-node-group"
    node_role_arn   = aws_iam_role.my_node_role.arn
    subnet_ids      = [aws_subnet.my_subnet.id, aws_subnet.my_subnet_2.id]
    scaling_config {
        desired_size = 3
        min_size     = 1
        max_size     = 5
    }
  
}