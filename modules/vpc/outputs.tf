output "vpc_id" {
  description = "Identifier of the created VPC"
  value       = aws_vpc.this.id
}

output "public_subnet_ids" {
  description = "List of subnet IDs for the public tier"
  value       = aws_subnet.public[*].id
}

output "app_subnet_ids" {
  description = "List of subnet IDs for the compute tier"
  value       = aws_subnet.app[*].id
}

output "data_subnet_ids" {
  description = "List of subnet IDs for the isolated data tier"
  value       = aws_subnet.data[*].id
}
