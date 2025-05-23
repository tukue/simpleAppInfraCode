# VPC Module

This module creates a Virtual Private Cloud (VPC) with the following resources:

- A VPC with a specified CIDR block.
- Two public subnets in different availability zones.
- An internet gateway.
- A public route table with routes to the internet.

## Inputs

- `vpc_cidr`: CIDR block for the VPC.
- `subnet_1_cidr`: CIDR block for Subnet 1.
- `subnet_2_cidr`: CIDR block for Subnet 2.

## Outputs

- `vpc_id`: The ID of the VPC.
- `subnet_1_id`: The ID of Subnet 1.
- `subnet_2_id`: The ID of Subnet 2.