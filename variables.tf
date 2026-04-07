variable "region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  description = "CIDR block for public subnet"
  default     = "10.0.1.0/24"
}

variable "ami_id" {
  description = "Amazon Linux 2 AMI for us-east-1"
  default     = "ami-0c02fb55956c7d316"
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t2.micro"
}

variable "project_name" {
  description = "Project name for tagging"
  default     = "tf-aws-infra"
}
