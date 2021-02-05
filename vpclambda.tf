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


module "renderer_compositor_child_lambda"  {

  source = "./modules/vpcLambdaPackage"
  filename = "renderer_compositor_child"
  role = aws_iam_role.choirlessLambdaRole.arn
  layers = [aws_lambda_layer_version.choirlessPythonLayer.arn, aws_lambda_layer_version.choirlessFfmpegLayer.arn]
  memory_size = 1024
  timeout       = 300
  efs_access_point = aws_efs_access_point.choirlessEFSAP.arn
  local_mount_path = var.mount_path
  subnet_ids = [aws_subnet.choirlessEFSSubnet1.id, aws_subnet.choirlessEFSSubnet2.id]
  security_group_ids = [aws_vpc.choirlessEFSVPC.default_security_group_id]

  env_variables = {
      SRC_BUCKET = aws_s3_bucket.choirlessConverted.id
      DEST_BUCKET = aws_s3_bucket.choirlessFinalParts.id
      TMP_DIR = var.mount_path
  }
  tags = var.tags
}

module "renderer_final_lambda"  {

  source = "./modules/vpcLambdaPackage"
  filename = "renderer_final"
  role = aws_iam_role.choirlessLambdaRole.arn
  layers = [aws_lambda_layer_version.choirlessPythonLayer.arn, aws_lambda_layer_version.choirlessFfmpegLayer.arn]
  memory_size =  2048
  timeout       = 300
  efs_access_point = aws_efs_access_point.choirlessEFSAP.arn
  local_mount_path = var.mount_path
  subnet_ids = [aws_subnet.choirlessEFSSubnet1.id, aws_subnet.choirlessEFSSubnet2.id]
  security_group_ids = [aws_vpc.choirlessEFSVPC.default_security_group_id]

  env_variables = {
      SRC_BUCKET = aws_s3_bucket.choirlessFinalParts.id
      DEST_BUCKET = aws_s3_bucket.choirlessPreview.id
      TMP_DIR = var.mount_path
  }
  tags = var.tags

}

module "post_production_lambda" {

  source = "./modules/vpcLambdaPackage"
  filename = "post_production"
  role = aws_iam_role.choirlessLambdaRole.arn
  layers = [aws_lambda_layer_version.choirlessPythonLayer.arn, aws_lambda_layer_version.choirlessFfmpegLayer.arn]
  memory_size =  2048
  timeout       = 300
  efs_access_point = aws_efs_access_point.choirlessEFSAP.arn
  local_mount_path = var.mount_path
  subnet_ids = [aws_subnet.choirlessEFSSubnet1.id, aws_subnet.choirlessEFSSubnet2.id]
  security_group_ids = [aws_vpc.choirlessEFSVPC.default_security_group_id]

  env_variables = {
      SRC_BUCKET = aws_s3_bucket.choirlessPreview.id
      DEST_BUCKET = aws_s3_bucket.choirlessFinal.id
      DEFINITION_BUCKET = aws_s3_bucket.choirlessDefinition.id
      TMP_DIR = var.mount_path
      MISC_BUCKET = aws_s3_bucket.choirlessMisc.id
  }
  tags = var.tags

}
