
#create the nodejs layer for the API
resource "aws_lambda_layer_version" "choirlessAPILambdaLayer" {
  filename   = "../choirless_lambda/api/choirless_layer.zip"
  layer_name = "choirlessAPILambdaLayer-${terraform.workspace}"
  source_code_hash = filebase64sha256("../choirless_lambda/api/choirless_layer.zip")

  compatible_runtimes = ["nodejs12.x"]

}

# ffmpeg executable
resource "aws_lambda_layer_version" "choirlessFfmpegLayer" {
  filename   = "../choirless_lambda/pipeline/ffmpeg.zip"
  layer_name = "choirlessFfmpegLayer-${terraform.workspace}"
  source_code_hash = filebase64sha256("../choirless_lambda/pipeline/ffmpeg.zip")
  compatible_runtimes = ["python3.8","nodejs12.x"]
}

# ffprobe executable
resource "aws_lambda_layer_version" "choirlessFfProbeLayer" {
  filename   = "../choirless_lambda/pipeline/ffprobe.zip"
  layer_name = "choirlessFfProbeLayer-${terraform.workspace}"
  source_code_hash = filebase64sha256("../choirless_lambda/pipeline/ffprobe.zip")
  compatible_runtimes = ["python3.8","nodejs12.x"]
}

# python modules
resource "aws_lambda_layer_version" "choirlessPythonLayer" {
  filename   = "../choirless_lambda/pipeline/python.zip"
  layer_name = "choirlessPythonLayer-${terraform.workspace}"
  source_code_hash = filebase64sha256("../choirless_lambda/pipeline/python.zip")
  compatible_runtimes = ["python3.8"]
}
