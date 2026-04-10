# EKS Module

This module creates an Amazon Elastic Kubernetes Service (EKS) cluster with the following resources:

- An EKS cluster with a specified name.
- A security group for the cluster.
- An IAM role for the cluster.
- A node group with scaling configuration.

## Inputs

- `vpc_id`: The ID of the VPC.
- `subnet_ids`: List of subnet IDs.
- `cluster_name`: Name of the EKS cluster.
- `node_group_name`: Name of the node group.
- `desired_size`: Desired number of worker nodes.
- `min_size`: Minimum number of worker nodes.
- `max_size`: Maximum number of worker nodes.

## Outputs

- `cluster_name`: The name of the EKS cluster.
- `cluster_endpoint`: The endpoint of the EKS cluster.
- `cluster_security_group_id`: The security group ID attached to the EKS cluster.