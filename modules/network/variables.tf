variable "name" {
  description = "Name prefix for every resource, e.g. tf-aws-infra-dev"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "vpc_cidr must be a valid IPv4 CIDR block, e.g. 10.0.0.0/16."
  }
}

variable "azs" {
  description = "Availability zones to spread subnets across, in order"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "One public subnet CIDR per AZ (same order as azs)"
  type        = list(string)

  validation {
    condition     = length(var.public_subnet_cidrs) > 0
    error_message = "At least one public subnet is required."
  }
}

variable "private_subnet_cidrs" {
  description = "One private subnet CIDR per AZ (same order as azs); empty for none"
  type        = list(string)
  default     = []
}

variable "enable_nat_gateway" {
  description = "Give private subnets outbound internet through a single NAT gateway (billed hourly)"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags added to every resource"
  type        = map(string)
  default     = {}
}
