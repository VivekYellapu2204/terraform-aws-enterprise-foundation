variable "aws_region" {
  type        = string
  description = "Target AWS region for infrastructure deployment"
  default     = "us-east-1"
}

variable "environment" {
  type        = string
  description = "Deployment environment tier identifier (e.g., production, staging)"
  default     = "production"
}

variable "vpc_cidr" {
  type        = string
  description = "Classless Inter-Domain Routing (CIDR) block allocated for the VPC"
  default     = "10.100.0.0/16"
}

variable "availability_zones" {
  type        = list(string)
  description = "List of Availability Zones targeted for multi-AZ topology"
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "enable_nat_ha" {
  type        = bool
  description = "Provision a dedicated NAT Gateway per AZ if true; provision a single shared NAT Gateway if false"
  default     = true
}

variable "custom_tags" {
  type        = map(string)
  description = "Custom metadata tags applied across all deployable resources"
  default     = {}
}
