#give s3 permissions toinvoke lambda 
resource "aws_lambda_permission" "allowTrigger" {
  statement_id  = "AllowS3ToExecuteTrigger"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = var.bucket.arn
}

//trigger lambda  from s3
resource "aws_s3_bucket_notification" "lambdaTrigger" {
    bucket = var.bucket.id

    lambda_function {
        lambda_function_arn = var.lambda.arn
        events        = var.events
    }

    depends_on = [
      aws_lambda_permission.allowTrigger
    ]
}
