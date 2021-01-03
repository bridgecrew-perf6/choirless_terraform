
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
    }
  }
  tags = var.tags

}

resource "aws_lambda_function" "snapshot" {
  filename      = "../choirless_lambda/pipeline/snapshot.zip"
  function_name = "snapshot"
  role          = aws_iam_role.choirlessLambdaRole.arn
  handler       = "snapshot.main"
  runtime       = "python3.8"
  timeout       = 10
  source_code_hash = filebase64sha256("../choirless_lambda/pipeline/snapshot.zip")
  layers = [aws_lambda_layer_version.choirlessFfmpegLayer.arn, aws_lambda_layer_version.choirlessPythonLayer.arn]
  environment {
    variables = {
      DEST_BUCKET = aws_s3_bucket.choirlessSnapshot.id
    }
  }
  tags = var.tags
}


