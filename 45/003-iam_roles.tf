resource "aws_iam_role" "cars_role" {
  name = "cars_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cars_attach" {
  role       = aws_iam_role.cars_role.name
  policy_arn = aws_iam_policy.cars_policy.arn
}
