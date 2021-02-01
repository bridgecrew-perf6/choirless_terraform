
##Note to future selves: Do NOT try to make these lambda functions with a for loop
## Have tried it before and run into problems. So just keep cutting and pasting!!!
## Also note: Lambda functions that have a vpc_config element are ones that exist inside a VPC,
## which gives them access to the EFS file system to process large files

resource "aws_lambda_function" "choirlessLambda" {
  filename      = "../choirless_lambda/pipeline/${var.filename}.zip"
  function_name = "${var.filename}-${terraform.workspace}"
  role          = var.role
  handler       = "${var.filename}.main"
  runtime       = var.runtime
  timeout       = var.timeout
  source_code_hash = filebase64sha256("../choirless_lambda/pipeline/${var.filename}.zip")
  layers = var.layers
  environment {
    variables = var.env_variables
  }
  tags = var.tags
}

# If the lambda invocation fails don't keep trying
resource "aws_lambda_function_event_invoke_config" "LambdaInvokeConfig" {
  function_name                = aws_lambda_function.choirlessLambda.function_name
  maximum_retry_attempts       = 0
}

resource "aws_cloudwatch_log_group" "lambdaLG" {
  name =  "/aws/lambda/${aws_lambda_function.choirlessLambda.function_name}"
  retention_in_days = 7
}

output "lambdaObject" {
  value = aws_lambda_function.choirlessLambda
}
