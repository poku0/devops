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

  request_models = {
    "application/json" = "Empty"
  }
}


resource "aws_api_gateway_integration" "post_car_lambda" {
  rest_api_id = aws_api_gateway_rest_api.cars_api.id
  resource_id = aws_api_gateway_resource.car.id
  http_method = aws_api_gateway_method.post_car.http_method

  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = "arn:aws:apigateway:${var.aws_region}:lambda:path/2015-03-31/functions/${aws_lambda_function.cars_function.arn}/invocations"

  request_templates = {
    "application/json" = <<EOF
$input.json('$')
EOF
  }
}

resource "aws_api_gateway_integration_response" "post_200" {
  rest_api_id = aws_api_gateway_rest_api.cars_api.id
  resource_id = aws_api_gateway_resource.car.id
  http_method = aws_api_gateway_method.post_car.http_method
  status_code = aws_api_gateway_method_response.post_200.status_code

  selection_pattern = ""

  response_templates = {
    "application/json" = <<EOF
{
  "message": "$input.path('$.message')"
}
EOF
  }
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
    aws_api_gateway_integration.post_car_lambda,
    aws_api_gateway_method_response.post_200,
    aws_api_gateway_integration_response.post_200
  ]
}


resource "aws_api_gateway_stage" "dev" {
  rest_api_id   = aws_api_gateway_rest_api.cars_api.id
  deployment_id = aws_api_gateway_deployment.cars_deployment.id
  stage_name    = "dev"
}

resource "aws_api_gateway_method_response" "post_200" {
  rest_api_id = aws_api_gateway_rest_api.cars_api.id
  resource_id = aws_api_gateway_resource.car.id
  http_method = aws_api_gateway_method.post_car.http_method
  status_code = "200"
}

