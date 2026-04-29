# ──────────────────────────────────────────────
# IAM Role for EC2 — SSM access
# ──────────────────────────────────────────────

data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ec2_ssm" {
  name               = "${var.project_name}-ec2-ssm-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json

  tags = {
    Name = "${var.project_name}-ec2-ssm-role"
  }
}

# Attach SSM managed policy — allows Session Manager access
resource "aws_iam_role_policy_attachment" "ssm_managed" {
  role       = aws_iam_role.ec2_ssm.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Attach CloudWatch agent policy — for log shipping
resource "aws_iam_role_policy_attachment" "cloudwatch" {
  role       = aws_iam_role.ec2_ssm.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# Custom policy for SSM Parameter Store read access
data "aws_iam_policy_document" "ssm_params" {
  statement {
    sid    = "ReadSSMParameters"
    effect = "Allow"
    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters",
      "ssm:GetParametersByPath"
    ]
    resources = [
      "arn:aws:ssm:${var.aws_region}:*:parameter/${var.project_name}/*"
    ]
  }
}

resource "aws_iam_policy" "ssm_params" {
  name        = "${var.project_name}-ssm-params-read"
  description = "Allow EC2 to read SSM parameters for ${var.project_name}"
  policy      = data.aws_iam_policy_document.ssm_params.json
}

resource "aws_iam_role_policy_attachment" "ssm_params" {
  role       = aws_iam_role.ec2_ssm.name
  policy_arn = aws_iam_policy.ssm_params.arn
}

# Instance profile — attaches the role to EC2
resource "aws_iam_instance_profile" "ec2_ssm" {
  name = "${var.project_name}-ec2-profile"
  role = aws_iam_role.ec2_ssm.name
}

# ──────────────────────────────────────────────
# GitHub Actions OIDC — allows CI/CD to deploy via SSM
# ──────────────────────────────────────────────

# OIDC identity provider for GitHub Actions
resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]

  tags = {
    Name = "github-actions-oidc"
  }
}

# Trust policy — only the specified repo can assume this role
data "aws_iam_policy_document" "github_actions_assume" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${var.github_repo}:*"]
    }
  }
}

# IAM role for GitHub Actions
resource "aws_iam_role" "github_actions" {
  name               = "${var.project_name}-github-actions"
  assume_role_policy = data.aws_iam_policy_document.github_actions_assume.json

  tags = {
    Name = "${var.project_name}-github-actions"
  }
}

# Policy — SSM RunCommand permissions for deployment
data "aws_iam_policy_document" "github_actions_deploy" {
  # Allow sending commands to the EC2 instance
  statement {
    sid    = "SSMSendCommand"
    effect = "Allow"
    actions = [
      "ssm:SendCommand"
    ]
    resources = [
      "arn:aws:ssm:${var.aws_region}::document/AWS-RunShellScript",
      aws_instance.app.arn
    ]
  }

  # Allow checking command execution status
  statement {
    sid    = "SSMCommandStatus"
    effect = "Allow"
    actions = [
      "ssm:GetCommandInvocation",
      "ssm:ListCommandInvocations"
    ]
    resources = ["*"]
  }

  # Allow waiting for command completion (ssm:DescribeInstanceInformation)
  statement {
    sid    = "SSMDescribe"
    effect = "Allow"
    actions = [
      "ssm:DescribeInstanceInformation"
    ]
    resources = ["*"]
  }

  # Allow discovering EC2 instance ID by tag (no hardcoded instance ID)
  statement {
    sid    = "EC2Discover"
    effect = "Allow"
    actions = [
      "ec2:DescribeInstances"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "github_actions_deploy" {
  name        = "${var.project_name}-github-actions-deploy"
  description = "Allow GitHub Actions to deploy via SSM RunCommand"
  policy      = data.aws_iam_policy_document.github_actions_deploy.json
}

resource "aws_iam_role_policy_attachment" "github_actions_deploy" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_actions_deploy.arn
}
