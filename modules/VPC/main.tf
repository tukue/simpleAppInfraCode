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
