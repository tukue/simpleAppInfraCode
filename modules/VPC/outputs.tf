output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "subnet_1_id" {
  description = "The ID of Subnet 1"
  value       = aws_subnet.subnet_1.id
}

output "subnet_2_id" {
  description = "The ID of Subnet 2"
  value       = aws_subnet.subnet_2.id
}

output "subnet_ids" {
  description = "List of subnet IDs"
  value       = [aws_subnet.subnet_1.id, aws_subnet.subnet_2.id]
}

output "route_table_id" {
  description = "The ID of the route table"
  value       = aws_route_table.main.id
}


