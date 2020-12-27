// create path in the API gateway
resource "aws_api_gateway_resource" "choirless_resource" {
  rest_api_id = var.api_id
  parent_id = var.api_root_resource_id
  path_part = var.api_path_part
}

// specify ANY HTTP method is allowed
resource "aws_api_gateway_method" "choirless_method" {
  rest_api_id = var.api_id
  resource_id = aws_api_gateway_resource.choirless_resource.id
  http_method = var.api_method
  authorization = "NONE"
}

// integrate this API call with its Lambda function
resource "aws_api_gateway_integration" "choirless_integration" {
  depends_on = [aws_api_gateway_method.choirless_method]
  rest_api_id = var.api_id
  resource_id = aws_api_gateway_resource.choirless_resource.id
  http_method  = aws_api_gateway_method.choirless_method.http_method
  integration_http_method = "POST"
  type = "AWS_PROXY"
  uri = "arn:aws:apigateway:${var.api_region}:lambda:path/2015-03-31/functions/${var.api_lambda_arn}/invocations"
  passthrough_behavior = "WHEN_NO_MATCH"
  content_handling = "CONVERT_TO_TEXT"
  cache_namespace = aws_api_gateway_resource.choirless_resource.id
  timeout_milliseconds = 5000 
}

// create an OPTIONS method for CORS
resource "aws_api_gateway_method" "choirless_options_method" {
  rest_api_id = var.api_id
  resource_id = aws_api_gateway_resource.choirless_resource.id
  http_method = "OPTIONS"
  authorization = "NONE"
}

// create an integration for the OPTIONS method
resource "aws_api_gateway_integration" "choirless_options_integration" {
  depends_on = [aws_api_gateway_method.choirless_options_method]
  rest_api_id = var.api_id
  resource_id = aws_api_gateway_resource.choirless_resource.id
  http_method  = aws_api_gateway_method.choirless_options_method.http_method
  type = "MOCK"
  passthrough_behavior = "WHEN_NO_MATCH"
  cache_namespace = aws_api_gateway_resource.choirless_resource.id
  timeout_milliseconds = 29000
  request_templates = {
    "application/json" = <<EOF
      {"statusCode": 200}
    EOF 
  }
}

# create method response 
resource "aws_api_gateway_method_response" "choirless_200" {
  rest_api_id = var.api_id
  resource_id = aws_api_gateway_resource.choirless_resource.id
  http_method = aws_api_gateway_method.choirless_options_method.http_method
  status_code = "200"
  response_parameters = {"method.response.header.Access-Control-Allow-Origin"=false,"method.response.header.Access-Control-Allow-Methods"=false ,"method.response.header.Access-Control-Allow-Headers"= false}
  response_models = {"application/json"="Empty"}
}

# create integration response
resource "aws_api_gateway_integration_response" "choirless_integration_response" {
  depends_on = [aws_api_gateway_integration.choirless_integration]
  rest_api_id = var.api_id
  resource_id = aws_api_gateway_resource.choirless_resource.id
  http_method = aws_api_gateway_method.choirless_options_method.http_method
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"= "'*'",
      "method.response.header.Access-Control-Allow-Methods"= "'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT'",
      "method.response.header.Access-Control-Allow-Headers"= "'*'"
    }
  response_templates = {"application/json"= ""}
}

resource "aws_lambda_permission" "allow_api_gateway" {
  function_name = var.api_lambda_name
  statement_id = var.api_lambda_name
  action = "lambda:*"
  principal = "apigateway.amazonaws.com"
  source_arn = "arn:aws:execute-api:${var.api_region}:${var.api_account_id}:${var.api_id}/*/*/${var.api_path_part}"
}


