variable "name" {
  description = "Name prefix for every resource, e.g. tf-aws-infra-dev"
  type        = string
}

variable "environment" {
  description = "Environment name shown on the web page (dev, prod, ...)"
  type        = string
}

variable "vpc_id" {
  description = "VPC to create the security group in"
  type        = string
}

variable "subnet_id" {
  description = "Subnet to launch the instance in"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "root_volume_size" {
  description = "Root volume size in GiB"
  type        = number
  default     = 8
}

variable "http_allowed_cidrs" {
  description = "CIDRs allowed to reach port 80"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "ssh_allowed_cidrs" {
  description = "CIDRs allowed to reach port 22; leave empty and use SSM Session Manager instead"
  type        = list(string)
  default     = []

  validation {
    condition     = !contains(var.ssh_allowed_cidrs, "0.0.0.0/0")
    error_message = "Do not open SSH to the whole internet; use a /32 or SSM Session Manager."
  }
}

variable "tags" {
  description = "Tags added to every resource"
  type        = map(string)
  default     = {}
}
