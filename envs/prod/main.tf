locals {
  environment = "prod"
  name        = "tf-aws-infra-${local.environment}"
}

module "network" {
  source = "../../modules/network"

  name                 = local.name
  vpc_cidr             = "10.1.0.0/16"
  azs                  = ["${var.region}a", "${var.region}b"]
  public_subnet_cidrs  = ["10.1.1.0/24", "10.1.2.0/24"]
  private_subnet_cidrs = ["10.1.11.0/24", "10.1.12.0/24"]
  enable_nat_gateway   = false
}

module "compute" {
  source = "../../modules/compute"

  name               = local.name
  environment        = local.environment
  vpc_id             = module.network.vpc_id
  subnet_id          = module.network.public_subnet_ids[0]
  instance_type      = "t3.small"
  ssh_allowed_cidrs  = var.ssh_allowed_cidrs
  http_allowed_cidrs = ["0.0.0.0/0"]
}
