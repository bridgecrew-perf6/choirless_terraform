
// lambda functions that power the API
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
      TABLE = aws_dynamodb_table.choirlessDB.name
    }
  }
  tags = var.tags

}


##Note to future selves: Do NOT try to make these lambda functions with a for loop
## Have tried it before and run into problems. So just keep cutting and pasting!!!
## Also note: Lambda functions that have a vpc_config element are ones that exist inside a VPC,
## which gives them access to the EFS file system to process large files


# snapshot
module "snapshot_lambda" {
  source = "./modules/lambdaPackage"
  filename = "snapshot"
  role = aws_iam_role.choirlessLambdaRole.arn
  layers = [aws_lambda_layer_version.choirlessFfmpegLayer.arn, aws_lambda_layer_version.choirlessAPILambdaLayer.arn]
  env_variables = {      
      DEST_BUCKET = aws_s3_bucket.choirlessSnapshot.id
      CONVERT_LAMBDA = module.convert_format_lambda.lambdaObject.function_name
  }
  tags = var.tags
}

# snapshot_final
module "snapshot_final_lambda" {
  source        = "./modules/lambdaPackage"
  filename      = "snapshot_final"
  role          = aws_iam_role.choirlessLambdaRole.arn
  layers        = [aws_lambda_layer_version.choirlessFfmpegLayer.arn, aws_lambda_layer_version.choirlessAPILambdaLayer.arn]
  env_variables = {      
      DEST_BUCKET = aws_s3_bucket.choirlessSnapshot.id
  }
  tags = var.tags
}

# calculate_alignment
module "calculate_alignment_lambda" {
  source        = "./modules/lambdaPackage"
  filename      = "calculate_alignment"
  role          = aws_iam_role.choirlessLambdaRole.arn
  layers        = [aws_lambda_layer_version.choirlessAPILambdaLayer.arn]
  env_variables = {      
      RENDERER_LAMBDA = module.renderer_lambda.lambdaObject.function_name
  }
  tags = var.tags
}

# renderer
module "renderer_lambda" {
  source        = "./modules/lambdaPackage"
  filename      = "renderer"
  role          = aws_iam_role.choirlessLambdaRole.arn
  layers        = [aws_lambda_layer_version.choirlessAPILambdaLayer.arn]
  env_variables = {      
      DEST_BUCKET = aws_s3_bucket.choirlessDefinition.id
      CHOIRLESS_API_KEY = aws_api_gateway_api_key.lambdasKey.value
      CHOIRLESS_API_URL = aws_api_gateway_deployment.choirless_api_deployment.invoke_url
  }
  tags = var.tags
}

# renderer_compositor_main
module "renderer_compositor_main_lambda" {
  source        = "./modules/lambdaPackage"
  filename      = "renderer_compositor_main"
  role          = aws_iam_role.choirlessLambdaRole.arn
  layers        = [aws_lambda_layer_version.choirlessAPILambdaLayer.arn]
  env_variables = {      
      COMPOSITOR_CHILD_LAMBDA = module.renderer_compositor_child_lambda.lambdaObject.function_name
  }
  tags = var.tags
}
