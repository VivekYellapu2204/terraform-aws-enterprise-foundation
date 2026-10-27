variable "environment" {
  type        = string
  description = "Environment tier identifier"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC"
}

variable "availability_zones" {
  type        = list(string)
  description = "Target Availability Zones"
}

variable "enable_nat_ha" {
  type        = bool
  description = "Flag to determine high-availability NAT Gateway distribution"
}
