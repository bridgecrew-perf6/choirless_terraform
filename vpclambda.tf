module "convert_format_lambda" {
  source = "./modules/vpcLambdaPackage"
  filename = "convert_format"
  role = aws_iam_role.choirlessLambdaRole.arn
  layers = [aws_lambda_layer_version.choirlessFfProbeLayer.arn, aws_lambda_layer_version.choirlessFfmpegLayer.arn, aws_lambda_layer_version.choirlessPythonLayer.arn]
  memory_size = 2048
  timeout       = 300
  efs_access_point = aws_efs_access_point.choirlessEFSAP.arn
  local_mount_path = var.mount_path
  subnet_ids = [aws_subnet.choirlessEFSSubnet1.id, aws_subnet.choirlessEFSSubnet2.id]
  security_group_ids = [aws_vpc.choirlessEFSVPC.default_security_group_id]

  env_variables = {      
      DEST_BUCKET = aws_s3_bucket.choirlessConverted.id
      STATUS_LAMBDA = aws_lambda_function.status.function_name
      TMP_DIR = var.mount_path
  }
  tags = var.tags
}

module "efs_cleaner_lambda" {
  source = "./modules/vpcLambdaPackage"
  filename = "efs_cleaner"
  runtime = "nodejs12.x"
  role = aws_iam_role.choirlessLambdaRole.arn
  efs_access_point = aws_efs_access_point.choirlessEFSAP.arn
  local_mount_path = var.mount_path
  subnet_ids = [aws_subnet.choirlessEFSSubnet1.id, aws_subnet.choirlessEFSSubnet2.id]
  security_group_ids = [aws_vpc.choirlessEFSVPC.default_security_group_id]

  env_variables = {      
      TMP_DIR = var.mount_path
  }
  tags = var.tags
}


resource "aws_lambda_function" "compositorChild" {
  filename      = "../choirless_lambda/pipeline/renderer_compositor_child.zip"
  function_name = "renderer_compositor_child-${terraform.workspace}"
  role          = aws_iam_role.choirlessLambdaRole.arn
  handler       = "renderer_compositor_child.main"
  runtime       = "python3.8"
  timeout       = 300
  memory_size   = 1024
  source_code_hash = filebase64sha256("../choirless_lambda/pipeline/renderer_compositor_child.zip")
  file_system_config {
    arn = aws_efs_access_point.choirlessEFSAP.arn
    local_mount_path = var.mount_path
  }

  vpc_config  {
    subnet_ids = [aws_subnet.choirlessEFSSubnet1.id, aws_subnet.choirlessEFSSubnet2.id]
    security_group_ids = [aws_vpc.choirlessEFSVPC.default_security_group_id]
  }

  depends_on = [aws_efs_mount_target.choirlessEFSMount1, aws_efs_mount_target.choirlessEFSMount2]

  layers = [aws_lambda_layer_version.choirlessPythonLayer.arn, aws_lambda_layer_version.choirlessFfmpegLayer.arn]
  environment {
    variables = {
      STATUS_LAMBDA = aws_lambda_function.status.function_name
      SRC_BUCKET = aws_s3_bucket.choirlessConverted.id
      DEST_BUCKET = aws_s3_bucket.choirlessFinalParts.id
      TMP_DIR = var.mount_path

    }
  }
  tags = var.tags
}

# If the lambda invocation fails don't keep trying
resource "aws_lambda_function_event_invoke_config" "compositorChildInvokeConfig" {
  function_name                = aws_lambda_function.compositorChild.function_name
  maximum_retry_attempts       = 0
}

resource "aws_lambda_function" "rendererFinal" {
  filename      = "../choirless_lambda/pipeline/renderer_final.zip"
  function_name = "renderer_final-${terraform.workspace}"
  role          = aws_iam_role.choirlessLambdaRole.arn
  handler       = "renderer_final.main"
  runtime       = "python3.8"
  timeout       = 300
  memory_size   = 2048
  source_code_hash = filebase64sha256("../choirless_lambda/pipeline/renderer_final.zip")

  file_system_config {
    arn = aws_efs_access_point.choirlessEFSAP.arn
    local_mount_path = var.mount_path
  }

  vpc_config  {
    subnet_ids = [aws_subnet.choirlessEFSSubnet1.id, aws_subnet.choirlessEFSSubnet2.id]
    security_group_ids = [aws_vpc.choirlessEFSVPC.default_security_group_id]
  }

  depends_on = [aws_efs_mount_target.choirlessEFSMount1, aws_efs_mount_target.choirlessEFSMount2]

  layers = [aws_lambda_layer_version.choirlessPythonLayer.arn, aws_lambda_layer_version.choirlessFfmpegLayer.arn]
  environment {
    variables = {
      STATUS_LAMBDA = aws_lambda_function.status.function_name
      SRC_BUCKET = aws_s3_bucket.choirlessFinalParts.id
      DEST_BUCKET = aws_s3_bucket.choirlessPreview.id
      TMP_DIR = var.mount_path

    }
  }
  tags = var.tags
}

# If the lambda invocation fails don't keep trying
resource "aws_lambda_function_event_invoke_config" "rendererFinalInvokeConfig" {
  function_name                = aws_lambda_function.rendererFinal.function_name
  maximum_retry_attempts       = 0
}

resource "aws_lambda_function" "postProduction" {
  filename      = "../choirless_lambda/pipeline/post_production.zip"
  function_name = "post_production-${terraform.workspace}"
  role          = aws_iam_role.choirlessLambdaRole.arn
  handler       = "post_production.main"
  runtime       = "python3.8"
  timeout       = 300
  memory_size   = 2048
  source_code_hash = filebase64sha256("../choirless_lambda/pipeline/post_production.zip")

  file_system_config {
    arn = aws_efs_access_point.choirlessEFSAP.arn
    local_mount_path = var.mount_path
  }

  vpc_config  {
    subnet_ids = [aws_subnet.choirlessEFSSubnet1.id, aws_subnet.choirlessEFSSubnet2.id]
    security_group_ids = [aws_vpc.choirlessEFSVPC.default_security_group_id]
  }

  depends_on = [aws_efs_mount_target.choirlessEFSMount1, aws_efs_mount_target.choirlessEFSMount2]

  layers = [aws_lambda_layer_version.choirlessPythonLayer.arn, aws_lambda_layer_version.choirlessFfmpegLayer.arn]
  environment {
    variables = {
      STATUS_LAMBDA = aws_lambda_function.status.function_name
      SRC_BUCKET = aws_s3_bucket.choirlessPreview.id
      DEST_BUCKET = aws_s3_bucket.choirlessFinal.id
      DEFINITION_BUCKET = aws_s3_bucket.choirlessDefinition.id
      TMP_DIR = var.mount_path
      MISC_BUCKET = aws_s3_bucket.choirlessMisc.id

    }
  }
  tags = var.tags
}

# If the lambda invocation fails don't keep trying
resource "aws_lambda_function_event_invoke_config" "postProductionInvokeConfig" {
  function_name                = aws_lambda_function.postProduction.function_name
  maximum_retry_attempts       = 0
}
