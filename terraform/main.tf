# Modular Networking: VPC, Subnets, Gateways, Route Tables
module "vpc" {
  source = "./modules/vpc"

  environment        = var.environment
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones
  enable_nat_ha      = var.enable_nat_ha
}

# Modular Security: KMS Encryption, VPC Flow Logs, Layered Security Groups
module "security" {
  source = "./modules/security"

  environment = var.environment
  vpc_id      = module.vpc.vpc_id
}

# Modular IAM Governance: SSM Execution Role and EC2 Instance Profiles
module "iam" {
  source = "./modules/iam"

  environment = var.environment
}
