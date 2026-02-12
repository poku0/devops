resource "aws_iam_policy" "cars_policy" {
  name        = "cars_policy"
  path        = "/"
  description = "serverless test"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "dynamodb:PutItem",
        ]
        Effect   = "Allow"
        Resource = aws_dynamodb_table.basic-dynamodb-table.arn
      },
    ]
  })
}
