resource "aws_api_gateway_rest_api" "cars_api" {
  name        = "cars-api"
  description = "Cars REST API"
}

resource "aws_api_gateway_resource" "car" {
  rest_api_id = aws_api_gateway_rest_api.cars_api.id
  parent_id   = aws_api_gateway_rest_api.cars_api.root_resource_id
  path_part   = "car"
}

resource "aws_api_gateway_method" "post_car" {
  rest_api_id   = aws_api_gateway_rest_api.cars_api.id
  resource_id   = aws_api_gateway_resource.car.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "post_car_lambda" {
  rest_api_id = aws_api_gateway_rest_api.cars_api.id
  resource_id = aws_api_gateway_resource.car.id
  http_method = aws_api_gateway_method.post_car.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.cars_function.invoke_arn
}

resource "aws_lambda_permission" "allow_apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cars_function.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.cars_api.execution_arn}/*/*"
}

resource "aws_api_gateway_deployment" "cars_deployment" {
  rest_api_id = aws_api_gateway_rest_api.cars_api.id

  depends_on = [
    aws_api_gateway_integration.post_car_lambda
  ]
}

resource "aws_api_gateway_stage" "dev" {
  rest_api_id   = aws_api_gateway_rest_api.cars_api.id
  deployment_id = aws_api_gateway_deployment.cars_deployment.id
  stage_name    = "dev"
}
