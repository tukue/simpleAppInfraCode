# modules/vpc/main.tf

resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "eks-vpc"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "eks-igw"
  }
}

resource "aws_subnet" "subnet_1" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.subnet_1_cidr
  availability_zone       = "eu-north-1c"
  map_public_ip_on_launch = true  # Enable auto-assign public IP

  tags = {
    Name = "Subnet 1 (eu-north-1c)"
  }
}

resource "aws_subnet" "subnet_2" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.subnet_2_cidr
  availability_zone       = "eu-north-1b"
  map_public_ip_on_launch = true  # Enable auto-assign public IP

  tags = {
    Name = "Subnet 2 (eu-north-1b)"
  }
}

# Create a route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name = "Public Route Table"
  }
}

# Associate the subnets with the route table
resource "aws_route_table_association" "subnet_1" {
  subnet_id      = aws_subnet.subnet_1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "subnet_2" {
  subnet_id      = aws_subnet.subnet_2.id
  route_table_id = aws_route_table.public.id
}
