# EC2 Assume Role Policy
data "aws_iam_policy_document" "ec2_trust" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "compute_instance_role" {
  name               = "${var.environment}-compute-instance-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_trust.json

  tags = {
    Name = "${var.environment}-compute-role"
  }
}

# Attach Standard AWS Managed Policies for SSM and Logging
resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.compute_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "cloudwatch_logs" {
  role       = aws_iam_role.compute_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# EC2 Instance Profile for Launch Templates
resource "aws_iam_instance_profile" "compute" {
  name = "${var.environment}-compute-instance-profile"
  role = aws_iam_role.compute_instance_role.name

  tags = {
    Name = "${var.environment}-compute-profile"
  }
}
