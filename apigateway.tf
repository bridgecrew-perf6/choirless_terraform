# create an API gateway
resource "aws_api_gateway_rest_api" "choirless_api" {
  name = "choirless-${terraform.workspace}"

  tags = var.tags
}

module "api_method" {
  for_each = toset(var.api_methods)
  source = "./modules/apimethod"
  api_id = aws_api_gateway_rest_api.choirless_api.id
  api_root_resource_id = aws_api_gateway_rest_api.choirless_api.root_resource_id
  api_path_part = each.key
  api_method = "POST" 
  api_lambda_arn = aws_lambda_function.lambda[each.key].arn
  api_lambda_name = aws_lambda_function.lambda[each.key].function_name
  api_region = data.aws_region.current.name
  api_account_id = data.aws_caller_identity.current.account_id
}

# create api gateway deployment
resource "aws_api_gateway_deployment" "choirless_api_deployment" {
  depends_on = [module.api_method]
  rest_api_id = aws_api_gateway_rest_api.choirless_api.id
  stage_name = terraform.workspace
}

