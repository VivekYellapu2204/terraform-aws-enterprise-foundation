output "vpc_id" {
  description = "The ID of the provisioned VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "Subnet identifiers for the public/ingress tier"
  value       = module.vpc.public_subnet_ids
}

output "private_app_subnet_ids" {
  description = "Subnet identifiers for the private compute tier"
  value       = module.vpc.app_subnet_ids
}

output "isolated_data_subnet_ids" {
  description = "Subnet identifiers for the air-gapped data tier"
  value       = module.vpc.data_subnet_ids
}

output "kms_key_arn" {
  description = "ARN of the Customer Managed Key used for storage encryption"
  value       = module.security.kms_key_arn
}

output "alb_security_group_id" {
  description = "Security group ID guarding external ingress into ALBs"
  value       = module.security.alb_security_group_id
}

output "app_security_group_id" {
  description = "Security group ID guarding private compute instances"
  value       = module.security.app_security_group_id
}

output "data_security_group_id" {
  description = "Security group ID guarding stateful database layers"
  value       = module.security.data_security_group_id
}

output "ec2_instance_profile_name" {
  description = "Instance profile name for credential-less SSM operational access"
  value       = module.iam.instance_profile_name
}
