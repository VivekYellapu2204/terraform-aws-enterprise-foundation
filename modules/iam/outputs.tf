output "instance_profile_name" {
  description = "Instance profile name to attach to EC2 launch templates"
  value       = aws_iam_instance_profile.compute.name
}

output "instance_profile_arn" {
  description = "ARN of the instance profile"
  value       = aws_iam_instance_profile.compute.arn
}

output "role_arn" {
  description = "ARN of the compute instance IAM role"
  value       = aws_iam_role.compute_instance_role.arn
}
