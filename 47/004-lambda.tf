# Lambda function
resource "aws_lambda_function" "cars_function" {
  function_name = "cars_function"
  role          = aws_iam_role.cars_role.arn
  handler       = "cars_function.lambda_handler"
  runtime       = "python3.12"
  filename      = "/Users/povilas/CA/45/lambda/cars_function.py.zip"


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

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.cars_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
