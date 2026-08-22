# Demo infra config for Pipeline Doctor's "risky change" detection.
#
# This file is deliberately checked in with an overly broad IAM policy.
# The pipeline will PASS (terraform validate/plan succeeds) but Pipeline
# Doctor's diff-scan should flag this as a risky production/infra change
# that needs human approval before merge -- even though nothing "failed."

resource "aws_iam_policy" "app_permissions" {
  name        = "app-permissions"
  description = "Permissions for the demo app"

  # RISKY: wildcard action + wildcard resource on an IAM policy.
  # A real reviewer (or Pipeline Doctor) should flag "iam:*" / "*" here.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "iam:*"
        Resource = "*"
      }
    ]
  })
}

resource "aws_security_group" "app_sg" {
  name        = "app-sg"
  description = "Security group for the demo app"

  # RISKY: open ingress from anywhere on all ports.
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
