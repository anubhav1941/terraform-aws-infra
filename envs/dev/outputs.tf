output "vpc_id" {
  description = "VPC ID"
  value       = module.network.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.network.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = module.network.private_subnet_ids
}

output "ec2_instance_id" {
  description = "EC2 instance ID"
  value       = module.compute.instance_id
}

output "ec2_public_ip" {
  description = "EC2 public IP"
  value       = module.compute.public_ip
}

output "web_url" {
  description = "Test page URL"
  value       = module.compute.url
}

output "security_group_id" {
  description = "Security group ID"
  value       = module.compute.security_group_id
}
