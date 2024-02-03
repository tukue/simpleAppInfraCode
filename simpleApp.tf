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

# Create a subnet
resource "aws_subnet" "my_subnet" {
    vpc_id                  = aws_vpc.my_vpc.id
    cidr_block              = "10.0.0.0/24"  # 
    availability_zone       = "eu-north-1c"  # 

    tags = {
        Name = "subnet-1"
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


# Output the VPC ID
output "vpc_id" {
    value = aws_vpc.my_vpc.id
}
