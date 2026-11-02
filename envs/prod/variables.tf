variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "ssh_allowed_cidrs" {
  description = "Your IP as a /32 if you need SSH; empty means SSM Session Manager only"
  type        = list(string)
  default     = []
}
