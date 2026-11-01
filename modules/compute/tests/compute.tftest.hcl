# Offline tests: the AWS provider is mocked, nothing is created and no credentials are needed.
mock_provider "aws" {
  mock_data "aws_iam_policy_document" {
    defaults = {
      json = "{\"Version\":\"2012-10-17\",\"Statement\":[]}"
    }
  }
}

variables {
  name        = "test"
  environment = "test"
  vpc_id      = "vpc-12345678"
  subnet_id   = "subnet-12345678"
}

run "instance_is_hardened" {
  command = apply

  assert {
    condition     = aws_instance.web.metadata_options[0].http_tokens == "required"
    error_message = "IMDSv2 must be required."
  }

  assert {
    condition     = aws_instance.web.root_block_device[0].encrypted
    error_message = "Root volume must be encrypted."
  }

  assert {
    condition     = aws_instance.web.root_block_device[0].volume_type == "gp3"
    error_message = "Root volume should be gp3."
  }

  assert {
    condition     = aws_iam_role_policy_attachment.ssm.policy_arn == "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    error_message = "Instance role must allow SSM Session Manager."
  }
}

run "ssh_is_closed_by_default" {
  command = plan

  assert {
    condition     = length(aws_vpc_security_group_ingress_rule.ssh) == 0
    error_message = "No SSH rule should exist unless ssh_allowed_cidrs is set."
  }

  assert {
    condition     = length(aws_vpc_security_group_ingress_rule.http) == 1
    error_message = "HTTP should be open by default."
  }
}

run "ssh_opens_only_for_listed_cidrs" {
  command = plan

  variables {
    ssh_allowed_cidrs = ["203.0.113.10/32"]
  }

  assert {
    condition     = aws_vpc_security_group_ingress_rule.ssh["203.0.113.10/32"].cidr_ipv4 == "203.0.113.10/32"
    error_message = "SSH should open only to the listed CIDR."
  }
}

run "refuses_ssh_from_the_internet" {
  command = plan

  variables {
    ssh_allowed_cidrs = ["0.0.0.0/0"]
  }

  expect_failures = [var.ssh_allowed_cidrs]
}
