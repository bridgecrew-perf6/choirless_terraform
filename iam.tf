resource "aws_iam_role" "choirlessLambdaRole" {
  name = "choirlessLambdaRole-${terraform.workspace}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = var.tags
}

//add inline policy that allows writing to logs and invoking lambda functions

resource "aws_iam_role_policy" "choirlessInlinePolicy" {
  name = "choirlessInlinePolicy"
  role = aws_iam_role.choirlessLambdaRole.id

  policy = <<-EOF
  {
    "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Action": [
                    "logs:CreateLogGroup",
                    "logs:CreateLogStream",
                    "logs:PutLogEvents"
                ],
                "Resource": "arn:aws:logs:*:*:*"
            },
            { 
                "Effect": "Allow", 
                "Action": [ "lambda:InvokeFunction" ], 
                "Resource": ["*"]
	    },
            { 
                "Effect": "Allow",
                "Action": [ "s3:Get*",
            		    "s3:List*",
                            "s3:*Object"],
                "Resource": ["${aws_s3_bucket.choirlessRaw.arn}",
                             "${aws_s3_bucket.choirlessRaw.arn}/*",
			     "${aws_s3_bucket.choirlessSnapshot.arn}",
                             "${aws_s3_bucket.choirlessSnapshot.arn}/*"
			    ]
            }

        ]
  }
  EOF
}

