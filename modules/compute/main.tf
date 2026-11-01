# ── AMI: latest Amazon Linux 2023, resolved at plan time (no hard-coded AMI IDs) ──
data "aws_ssm_parameter" "al2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

# ── SECURITY GROUP ────────────────────────────────
resource "aws_security_group" "web" {
  name        = "${var.name}-web-sg"
  description = "HTTP in from allowed CIDRs; SSH only if explicitly allowed; all out"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, { Name = "${var.name}-web-sg" })
}

resource "aws_vpc_security_group_ingress_rule" "http" {
  for_each = toset(var.http_allowed_cidrs)

  security_group_id = aws_security_group.web.id
  description       = "HTTP"
  cidr_ipv4         = each.value
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

# Empty by default: shell access goes through SSM Session Manager, not port 22.
resource "aws_vpc_security_group_ingress_rule" "ssh" {
  for_each = toset(var.ssh_allowed_cidrs)

  security_group_id = aws_security_group.web.id
  description       = "SSH"
  cidr_ipv4         = each.value
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "all" {
  security_group_id = aws_security_group.web.id
  description       = "All outbound"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# ── IAM: instance role for SSM Session Manager ────
data "aws_iam_policy_document" "ec2_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ec2" {
  name               = "${var.name}-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume.json

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2" {
  name = "${var.name}-ec2-profile"
  role = aws_iam_role.ec2.name

  tags = var.tags
}

# ── EC2 INSTANCE ──────────────────────────────────
resource "aws_instance" "web" {
  ami                    = data.aws_ssm_parameter.al2023.insecure_value # a public AMI ID, not a secret
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.web.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2.name

  user_data = templatefile("${path.module}/user_data.sh.tftpl", {
    environment = var.environment
  })
  user_data_replace_on_change = true

  # IMDSv2 only: blocks the SSRF-to-credentials path that IMDSv1 allows
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  root_block_device {
    volume_type           = "gp3"
    volume_size           = var.root_volume_size
    encrypted             = true
    delete_on_termination = true
  }

  tags = merge(var.tags, { Name = "${var.name}-web" })

  lifecycle {
    # A new AMI release should not silently replace a running instance on the next apply
    ignore_changes = [ami]
  }
}
