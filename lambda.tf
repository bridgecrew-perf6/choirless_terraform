
#create the nodejs layer for the API
resource "aws_lambda_layer_version" "choirlessAPILambdaLayer" {
  filename   = "../choirless_lambda/api/choirless_layer.zip"
  layer_name = "choirlessAPILambdaLayer-${terraform.workspace}"
  source_code_hash = filebase64sha256("../choirless_lambda/api/choirless_layer.zip")

  compatible_runtimes = ["nodejs12.x"]

}

resource "aws_lambda_layer_version" "choirlessFfmpegLayer" {
  filename   = "../choirless_lambda/pipeline/ffmpeg.zip"
  layer_name = "choirlessFfmpegLayer-${terraform.workspace}"
  source_code_hash = filebase64sha256("../choirless_lambda/pipeline/ffmpeg.zip")
  compatible_runtimes = ["python3.8","nodejs12.x"]
}

resource "aws_lambda_layer_version" "choirlessFfProbeLayer" {
  filename   = "../choirless_lambda/pipeline/ffprobe.zip"
  layer_name = "choirlessFfProbeLayer-${terraform.workspace}"
  source_code_hash = filebase64sha256("../choirless_lambda/pipeline/ffprobe.zip")
  compatible_runtimes = ["python3.8","nodejs12.x"]
}

resource "aws_lambda_layer_version" "choirlessPythonLayer" {
  filename   = "../choirless_lambda/pipeline/python.zip"
  layer_name = "choirlessPythonLayer-${terraform.workspace}"
  source_code_hash = filebase64sha256("../choirless_lambda/pipeline/python.zip")
  compatible_runtimes = ["python3.8"]
}


resource "aws_lambda_function" "lambda" {
  for_each = toset(var.api_methods) 
  filename      = "../choirless_lambda/api/${each.key}.zip"
  function_name = "${each.key}-${terraform.workspace}"
  role          = aws_iam_role.choirlessLambdaRole.arn
  handler       = "${each.key}.handler"
  runtime       = "nodejs12.x"
  timeout       = 10
  source_code_hash = filebase64sha256("../choirless_lambda/api/${each.key}.zip")
  layers = [aws_lambda_layer_version.choirlessAPILambdaLayer.arn]
  
  environment {
    variables = {
      COUCH_URL = var.COUCH_URL
      COUCH_USERS_DATABASE = "choirless_users"
      COUCH_RENDER_DATABASE = "choirless_render"
    }
  }
  tags = var.tags

}


##Note to future selves: Do NOT try to make these lambda functions with a for loop
## Have tried it before and run into problems. So just keep cutting and pasting!!!


resource "aws_lambda_function" "snapshot" {
  filename      = "../choirless_lambda/pipeline/snapshot.zip"
  function_name = "snapshot-${terraform.workspace}"
  role          = aws_iam_role.choirlessLambdaRole.arn
  handler       = "snapshot.main"
  runtime       = "python3.8"
  timeout       = 10
  source_code_hash = filebase64sha256("../choirless_lambda/pipeline/snapshot.zip")
  layers = [aws_lambda_layer_version.choirlessFfmpegLayer.arn, aws_lambda_layer_version.choirlessPythonLayer.arn]
  environment {
    variables = {
      DEST_BUCKET = aws_s3_bucket.choirlessSnapshot.id
      STATUS_LAMBDA = aws_lambda_function.status.function_name
    }
  }
  tags = var.tags
}

# If the lambda invocation fails don't keep trying
resource "aws_lambda_function_event_invoke_config" "snapshotInvokeConfig" {
  function_name                = aws_lambda_function.snapshot.function_name
  maximum_retry_attempts       = 0
}


resource "aws_lambda_function" "convertFormat" {
  filename      = "../choirless_lambda/pipeline/convert_format.zip"
  function_name = "convert_format-${terraform.workspace}"
  role          = aws_iam_role.choirlessLambdaRole.arn
  handler       = "convert_format.main"
  runtime       = "python3.8"
  timeout       = 10
  source_code_hash = filebase64sha256("../choirless_lambda/pipeline/convert_format.zip")
  layers = [aws_lambda_layer_version.choirlessFfProbeLayer.arn, aws_lambda_layer_version.choirlessFfmpegLayer.arn, aws_lambda_layer_version.choirlessPythonLayer.arn]
  environment {
    variables = {
      DEST_BUCKET = aws_s3_bucket.choirlessConverted.id
    }
  }
  tags = var.tags
}

# If the lambda invocation fails don't keep trying
resource "aws_lambda_function_event_invoke_config" "convertFormatInvokeConfig" {
  function_name                = aws_lambda_function.convertFormat.function_name
  maximum_retry_attempts       = 0
}


resource "aws_lambda_function" "status" {
  filename      = "../choirless_lambda/pipeline/status.zip"
  function_name = "status-${terraform.workspace}"
  role          = aws_iam_role.choirlessLambdaRole.arn
  handler       = "status.main"
  runtime       = "python3.8"
  timeout       = 10
  source_code_hash = filebase64sha256("../choirless_lambda/pipeline/status.zip")
  layers = [aws_lambda_layer_version.choirlessPythonLayer.arn]
  environment {
    variables = {
      CHOIRLESS_API_URL = aws_api_gateway_deployment.choirless_api_deployment.invoke_url
    }
  }
  tags = var.tags
}

# If the lambda invocation fails don't keep trying
resource "aws_lambda_function_event_invoke_config" "statusInvokeConfig" {
  function_name                = aws_lambda_function.status.function_name
  maximum_retry_attempts       = 0
}

