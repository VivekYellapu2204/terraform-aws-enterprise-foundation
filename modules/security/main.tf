data "aws_caller_identity" "current" {}

# Customer Managed Key (CMK) for Infrastructure Encryption
resource "aws_kms_key" "infra" {
  description             = "CMK for ${var.environment} infrastructure data-at-rest encryption"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "EnableRootIAMAccess"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "AllowCloudWatchLogsEncryption"
        Effect = "Allow"
        Principal = {
          Service = "logs.amazonaws.com"
        }
        Action = [
          "kms:Encrypt*",
          "kms:Decrypt*",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:Describe*"
        ]
        Resource = "*"
      }
    ]
  })

  tags = {
    Name = "${var.environment}-infra-kms"
  }
}

resource "aws_kms_alias" "infra" {
  name          = "alias/${var.environment}-infra-key"
  target_key_id = aws_kms_key.infra.key_id
}

# Dedicated S3 Bucket for Centralized VPC Flow Logs
resource "aws_s3_bucket" "flow_logs" {
  bucket_prefix = "${var.environment}-vpc-flow-logs-"
  force_destroy = false

  tags = {
    Name = "${var.environment}-vpc-flow-logs"
  }
}

resource "aws_s3_bucket_public_access_block" "flow_logs" {
  bucket = aws_s3_bucket.flow_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "flow_logs" {
  bucket = aws_s3_bucket.flow_logs.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.infra.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_versioning" "flow_logs" {
  bucket = aws_s3_bucket.flow_logs.id
  versioning_configuration {
    status = "Enabled"
  }
}

# VPC Flow Log Resource
resource "aws_flow_log" "this" {
  log_destination      = aws_s3_bucket.flow_logs.arn
  log_destination_type = "s3"
  traffic_type         = "ALL"
  vpc_id               = var.vpc_id

  tags = {
    Name = "${var.environment}-vpc-flow-log"
  }
}

# Security Group: Ingress Load Balancer Tier
resource "aws_security_group" "alb" {
  name        = "${var.environment}-alb-sg"
  description = "Ingress control for perimeter Application Load Balancers"
  vpc_id      = var.vpc_id

  ingress {
    description = "Enforce TLS inbound traffic"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Outbound to private workloads"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-alb-sg"
  }
}

# Security Group: Private Compute Workload Tier
resource "aws_security_group" "app" {
  name        = "${var.environment}-app-sg"
  description = "Access control for application compute tier"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow traffic exclusively from perimeter ALB"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    description = "Allow egress to external repositories via NAT"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-app-sg"
  }
}

# Security Group: Isolated Database Tier
resource "aws_security_group" "data" {
  name        = "${var.environment}-data-sg"
  description = "Air-gapped database layer access control"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Database access exclusively from compute layer"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
  }

  egress {
    description = "Block open egress; default rule prevents external connectivity"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = []
  }

  tags = {
    Name = "${var.environment}-data-sg"
  }
}
