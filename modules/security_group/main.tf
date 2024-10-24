# Create a security group
resource "aws_security_group" "my_security_group" {
    name        = "my-security-group"
    description = "Security group for EKS cluster"

    vpc_id = aws_vpc.my_vpc.id

    ingress {
        from_port   = 0
        to_port     = 65535
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
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
        from_port   = 0
        to_port     = 65535
        protocol    = "tcp"
        security_groups = [aws_security_group.my_security_group.id] # Reference the security group created for the EKS cluster
    } 

    # Create a security group for worker nodes
resource "aws_security_group" "worker_node_security_group" {
    name        = "worker-node-security-group"
    description = "Security group for worker nodes to communicate with EKS control plane"

    vpc_id = aws_vpc.my_vpc.id

    ingress {
        from_port   = 0
        to_port     = 65535
        protocol    = "tcp"
        security_groups = [aws_security_group.my_security_group.id] # Reference the security group created for the EKS cluster
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
 

 # Create a security group
resource "aws_security_group" "my_security_group" {
    name        = "my-security-group"
    description = "Security group for EKS cluster"

    vpc_id = aws_vpc.my_vpc.id

    ingress {
        from_port   = 0
        to_port     = 65535
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
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