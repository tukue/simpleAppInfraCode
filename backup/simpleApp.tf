# Define the provider
provider "aws" {
    region = "eu-north-1"  
}

# Create a VPC
resource "aws_vpc" "my_vpc" {
    cidr_block = "10.0.0.0/16"  

    tags = {
        Name = "vpc-1"
    }
}

# Create an internet gateway
resource "aws_internet_gateway" "my_igw" {
    vpc_id = aws_vpc.my_vpc.id

    tags = {
        Name = "igw-1"
    }
}

# Create the first subnet in eu-north-1c
resource "aws_subnet" "my_subnet" {
    vpc_id                  = aws_vpc.my_vpc.id
    cidr_block              = "10.0.0.0/24"
    availability_zone       = "eu-north-1c"
    map_public_ip_on_launch = true  #enable auto-assign public IP
    tags = {
        Name = "subnet-1"
    }
}

# Create the second subnet in eu-north-1b
resource "aws_subnet" "my_subnet_2" {
    vpc_id                  = aws_vpc.my_vpc.id
    cidr_block              = "10.0.1.0/24"
    availability_zone       = "eu-north-1b"
    map_public_ip_on_launch = true  #enable auto-assign public IP
    tags = {
        Name = "subnet-2"
    }
}

# Create a route table
resource "aws_route_table" "my_route_table" {
    vpc_id = aws_vpc.my_vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.my_igw.id
    }

    tags = {
        Name = "route-table-1"
    }
}

# Associate the subnet with the route table
resource "aws_route_table_association" "my_route_table_association" {
    subnet_id      = aws_subnet.my_subnet.id
    route_table_id = aws_route_table.my_route_table.id
} 

# Create an IAM role for EKS
resource "aws_iam_role" "my_eks_role" {
    name = "my-eks-role"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Effect = "Allow"
            Principal = {
              Service = "eks.amazonaws.com"
            }
            Action = "sts:AssumeRole"
          }
        ]
      })
}

# Attach the required policies to the IAM role
resource "aws_iam_role_policy_attachment" "my_eks_role_policy_attachment" {
    role       = aws_iam_role.my_eks_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "eks_service_role_service_policy" {
  role       = aws_iam_role.my_eks_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
}

# Create a security group
resource "aws_security_group" "my_security_group" {
    name        = "my-security-group"
    description = "Security group for EKS cluster"

    vpc_id = aws_vpc.my_vpc.id

    ingress {
        description = "HTTPS access from VPC"
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = [aws_vpc.my_vpc.cidr_block]
    }

    ingress {
        description = "NodePort Services"
        from_port   = 30000
        to_port     = 32767
        protocol    = "tcp"
        cidr_blocks = [aws_vpc.my_vpc.cidr_block]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "security-group-1"
    }
}

# Create a security group for worker nodes
resource "aws_security_group" "worker_node_security_group" {
    name        = "worker-node-security-group"
    description = "Security group for worker nodes to communicate with EKS control plane"

    vpc_id = aws_vpc.my_vpc.id

    ingress {
        description     = "Allow communication with control plane"
        from_port      = 0
        to_port        = 65535
        protocol       = "tcp"
        security_groups = [aws_security_group.my_security_group.id]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "worker-node-security-group"
    }
}

# Create an EKS cluster
resource "aws_eks_cluster" "my_eks_cluster" {
    name     = "my-eks-cluster"
    role_arn = aws_iam_role.my_eks_role.arn
    
    vpc_config {
        subnet_ids = [aws_subnet.my_subnet.id, aws_subnet.my_subnet_2.id]
        security_group_ids = [aws_security_group.my_security_group.id]
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

resource "aws_iam_role" "my_node_role" {
  name = "my_node_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "my_node_role_policy_attachment" {
  role       = aws_iam_role.my_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "my_node_role_cni_policy_attachment" {
  role       = aws_iam_role.my_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "eks_node_role_ecr_policy" {
  role       = aws_iam_role.my_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# Output the EKS cluster name
output "eks_cluster_name" {
    value = aws_eks_cluster.my_eks_cluster.name
}

# Output the VPC ID
output "vpc_id" {
    value = aws_vpc.my_vpc.id
}