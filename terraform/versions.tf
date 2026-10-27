terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Uncomment and configure for remote state management
  # backend "s3" {
  #   bucket         = "your-organization-tfstate-bucket"
  #   key            = "foundation/terraform.tfstate"
  #   region         = "us-east-1"
  #   dynamodb_table = "your-tfstate-locks"
  #   encrypt        = true
  # }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = merge(
      var.custom_tags,
      {
        Environment = var.environment
        ManagedBy   = "Terraform"
      }
    )
  }
}
