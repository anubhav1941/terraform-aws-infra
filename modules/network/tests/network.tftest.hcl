# Offline tests: the AWS provider is mocked, nothing is created and no credentials are needed.
mock_provider "aws" {}

variables {
  name                 = "test"
  vpc_cidr             = "10.0.0.0/16"
  azs                  = ["us-east-1a", "us-east-1b"]
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24"]
}

run "one_public_and_one_private_subnet_per_az" {
  command = apply

  assert {
    condition     = length(aws_subnet.public) == 2 && length(aws_subnet.private) == 2
    error_message = "Expected one public and one private subnet in each of the 2 AZs."
  }

  assert {
    condition     = aws_subnet.public["us-east-1b"].cidr_block == "10.0.2.0/24"
    error_message = "Subnet CIDRs must be assigned to AZs in order."
  }

  assert {
    condition     = alltrue([for s in aws_subnet.private : !s.map_public_ip_on_launch])
    error_message = "Private subnets must not auto-assign public IPs."
  }

  assert {
    condition     = length(output.public_subnet_ids) == 2
    error_message = "public_subnet_ids output should list both subnets."
  }
}

run "no_nat_gateway_by_default" {
  command = plan

  assert {
    condition     = length(aws_nat_gateway.this) == 0 && length(aws_eip.nat) == 0
    error_message = "NAT gateway is billed hourly and must be opt-in."
  }
}

run "nat_gateway_when_enabled" {
  command = plan

  variables {
    enable_nat_gateway = true
  }

  assert {
    condition     = length(aws_nat_gateway.this) == 1
    error_message = "enable_nat_gateway = true should create exactly one NAT gateway."
  }
}

run "public_only_network" {
  command = plan

  variables {
    private_subnet_cidrs = []
  }

  assert {
    condition     = length(aws_subnet.private) == 0
    error_message = "No private subnets should be created when none are requested."
  }
}

run "rejects_invalid_cidr" {
  command = plan

  variables {
    vpc_cidr = "not-a-cidr"
  }

  expect_failures = [var.vpc_cidr]
}
