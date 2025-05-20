output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = aws_eks_cluster.eks_cluster.name
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = aws_eks_cluster.eks_cluster.endpoint
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = aws_security_group.eks_sg.id
}

output "worker_node_ips" {
  description = "The IP addresses of the EKS worker nodes"
  value       = aws_eks_node_group.node_group.resources != null ? data.aws_instances.worker_nodes.private_ips : []
}

# Data source to get worker node IPs
data "aws_instances" "worker_nodes" {
  filter {
    name   = "tag:eks:cluster-name"
    values = [aws_eks_cluster.eks_cluster.name]
  }
  
  filter {
    name   = "tag:eks:nodegroup-name"
    values = [aws_eks_node_group.node_group.node_group_name]
  }
  
  depends_on = [aws_eks_node_group.node_group]
}