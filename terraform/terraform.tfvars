aws_region         = "us-east-1"
environment        = "production"
vpc_cidr           = "10.100.0.0/16"
availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
enable_nat_ha      = true

custom_tags = {
  Project   = "EnterprisePlatform"
  ManagedBy = "Terraform"
  CostCenter = "Infrastructure-Core"
}
