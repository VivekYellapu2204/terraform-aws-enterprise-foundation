output "kms_key_arn" {
  description = "ARN of the infrastructure Customer Managed Key"
  value       = aws_kms_key.infra.arn
}

output "flow_logs_bucket_arn" {
  description = "ARN of the VPC Flow Logs destination S3 bucket"
  value       = aws_s3_bucket.flow_logs.arn
}

output "alb_security_group_id" {
  description = "Security Group ID of the perimeter ALB"
  value       = aws_security_group.alb.id
}

output "app_security_group_id" {
  description = "Security Group ID of the private application compute layer"
  value       = aws_security_group.app.id
}

output "data_security_group_id" {
  description = "Security Group ID of the isolated database layer"
  value       = aws_security_group.data.id
}
