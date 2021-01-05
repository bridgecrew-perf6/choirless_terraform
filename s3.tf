#buckets

resource "aws_s3_bucket" "choirlessRaw" {
  bucket = "choirless-raw-${terraform.workspace}"
  tags = var.tags
}

resource "aws_s3_bucket" "choirlessSnapshot" {
  bucket = "choirless-snapshot-${terraform.workspace}"
  tags = var.tags
}

resource "aws_s3_bucket" "choirlessConverted" {
  bucket = "choirless-converted-${terraform.workspace}"
  tags = var.tags
}

#triggers for buckets
module "raw_trigger" {
  source ="./modules/trigger"
  bucket = aws_s3_bucket.choirlessRaw
  lambda = aws_lambda_function.snapshot
  events = ["s3:ObjectCreated:*"]
}
