#buckets

resource "aws_s3_bucket" "choirlessRaw" {
  bucket = "choirless-raw-${terraform.workspace}"
  tags = var.tags
}

resource "aws_s3_bucket" "choirlessConverted" {
  bucket = "choirless-converted-${terraform.workspace}"
  tags = var.tags
}

resource "aws_s3_bucket" "choirlessSnapshot" {
  bucket = "choirless-snapshot-${terraform.workspace}"
  tags = var.tags
}

resource "aws_s3_bucket" "choirlessDefinition" {
  bucket = "choirless-definition-${terraform.workspace}"
  lifecycle_rule {
    id = "self-clean"
    enabled = true
    expiration {
      days = 1
    }
  }
  tags = var.tags
}

resource "aws_s3_bucket" "choirlessFinalParts" {
  bucket = "choirless-final-parts-${terraform.workspace}"
  lifecycle_rule {
    id = "self-clean"
    enabled = true
    expiration {
      days = 1
    }
  }
  tags = var.tags
}

resource "aws_s3_bucket" "choirlessPreview" {
  bucket = "choirless-preview-${terraform.workspace}"
  lifecycle_rule {
    id = "self-clean"
    enabled = true
    expiration {
      days = 1
    }
  }

  tags = var.tags
}

resource "aws_s3_bucket" "choirlessFinal" {
  bucket = "choirless-final-${terraform.workspace}"
  tags = var.tags
}

resource "aws_s3_bucket" "choirlessMisc" {
  bucket = "choirless-misc-${terraform.workspace}"
  tags = var.tags
}




#triggers for buckets
module "raw_trigger" {
  source ="./modules/trigger"
  bucket = aws_s3_bucket.choirlessRaw
  lambda = module.snapshot_lambda.lambdaObject
  events = ["s3:ObjectCreated:*"]
}

module "converted_trigger" {
  source ="./modules/trigger"
  bucket = aws_s3_bucket.choirlessConverted
  lambda = module.calculate_alignment_lambda.lambdaObject
  events = ["s3:ObjectCreated:*"]
}

module "definition_trigger" {
  source ="./modules/trigger"
  bucket = aws_s3_bucket.choirlessDefinition
  lambda = module.renderer_compositor_main_lambda.lambdaObject
  events = ["s3:ObjectCreated:*"]
}

module "final_parts_trigger" {
  source ="./modules/trigger"
  bucket = aws_s3_bucket.choirlessFinalParts
  lambda = module.renderer_final_lambda.lambdaObject
  events = ["s3:ObjectCreated:*"]
}

module "preview_trigger" {
  source ="./modules/trigger"
  bucket = aws_s3_bucket.choirlessPreview
  lambda = module.post_production_lambda.lambdaObject
  events = ["s3:ObjectCreated:*"]
}

module "final_trigger" {
  source ="./modules/trigger"
  bucket = aws_s3_bucket.choirlessFinal
  lambda = module.snapshot_final_lambda.lambdaObject
  events = ["s3:ObjectCreated:*"]
}


## upload files to the misc s3 from local misc directory
resource "aws_s3_bucket_object" "object1" {
  for_each = fileset("miscbucket/", "*")
  bucket = aws_s3_bucket.choirlessMisc.id
  key = each.value
  source = "miscbucket/${each.value}"
  etag = filemd5("miscbucket/${each.value}")
}
