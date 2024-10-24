# modules/vpc/outputs.tf

output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.this.id
}

output "subnet_1_id" {
  description = "The ID of Subnet 1 in eu-north-1c"
  value       = aws_subnet.subnet_1.id
}

output "subnet_2_id" {
  description = "The ID of Subnet 2 in eu-north-1b"
  value       = aws_subnet.subnet_2.id
}
