output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.this.id
}

output "public_subnet_ids" {
  description = "Public subnet IDs, in AZ order"
  value       = [for az in var.azs : aws_subnet.public[az].id if contains(keys(aws_subnet.public), az)]
}

output "private_subnet_ids" {
  description = "Private subnet IDs, in AZ order"
  value       = [for az in var.azs : aws_subnet.private[az].id if contains(keys(aws_subnet.private), az)]
}

output "internet_gateway_id" {
  description = "Internet gateway ID"
  value       = aws_internet_gateway.this.id
}
