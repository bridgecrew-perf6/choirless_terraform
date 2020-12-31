#buckets

resource "aws_s3_bucket" "choirlessRaw" {
  #for_each = toset(var.bucket_names)
  bucket = "choirless-raw-${terraform.workspace}"
  tags = var.tags
  
}


#triggers for buckets
module "raw_trigger" {
  source ="./modules/trigger"
  bucket = aws_s3_bucket.choirlessRaw
  lambda = aws_lambda_function.helloWorld
  events = ["s3:ObjectCreated:*"]

}
