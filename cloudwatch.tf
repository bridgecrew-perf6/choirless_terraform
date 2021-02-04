resource "aws_cloudwatch_event_rule" "every_one_day" {
  name                = "every-one-day"
  description         = "Fires every one day"
  schedule_expression = "rate(1 day)"
}

resource "aws_cloudwatch_event_target" "check_efs_every_one_day" {
  rule      = aws_cloudwatch_event_rule.every_one_day.name
  target_id = "lambda"
  arn       = module.efs_cleaner_lambda.lambdaObject.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_check_efs" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = module.efs_cleaner_lambda.lambdaObject.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.every_one_day.arn
}
