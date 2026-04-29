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
