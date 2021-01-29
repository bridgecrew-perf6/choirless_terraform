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
  lambda = aws_lambda_function.snapshot
  events = ["s3:ObjectCreated:*"]
}

module "converted_trigger" {
  source ="./modules/trigger"
  bucket = aws_s3_bucket.choirlessConverted
  lambda = aws_lambda_function.calculateAlignment
  events = ["s3:ObjectCreated:*"]
}

module "definition_trigger" {
  source ="./modules/trigger"
  bucket = aws_s3_bucket.choirlessDefinition
  lambda = aws_lambda_function.rendererCompositorMain
  events = ["s3:ObjectCreated:*"]
}

module "final_parts_trigger" {
  source ="./modules/trigger"
  bucket = aws_s3_bucket.choirlessFinalParts
  lambda = aws_lambda_function.rendererFinal
  events = ["s3:ObjectCreated:*"]
}

module "preview_trigger" {
  source ="./modules/trigger"
  bucket = aws_s3_bucket.choirlessPreview
  lambda = aws_lambda_function.postProduction
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
