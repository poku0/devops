# Lambda function
resource "aws_lambda_function" "cars_function" {
  function_name = "cars_function"
  role          = aws_iam_role.cars_role.arn
  handler       = "index.handler"
  runtime = "python3.12"
  filename = "/Users/povilas/CA/45/lambda/cars_function.py.zip"


  environment {
    variables = {
      ENVIRONMENT = "production"
      LOG_LEVEL   = "info"
    }
  }

  tags = {
    Environment = "production"
    Application = "cars"
  }
}
