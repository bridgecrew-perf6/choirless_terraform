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
                             "${aws_s3_bucket.choirlessSnapshot.arn}/*",
			     "${aws_s3_bucket.choirlessDefinition.arn}",
                             "${aws_s3_bucket.choirlessDefinition.arn}/*",
			     "${aws_s3_bucket.choirlessFinalParts.arn}",
                             "${aws_s3_bucket.choirlessFinalParts.arn}/*",
			     "${aws_s3_bucket.choirlessPreview.arn}",
                             "${aws_s3_bucket.choirlessPreview.arn}/*",
			     "${aws_s3_bucket.choirlessConverted.arn}",
                             "${aws_s3_bucket.choirlessConverted.arn}/*"
			    ]
            },
            {
            "Action": [
                "elastictranscoder:Read*",
                "elastictranscoder:List*",
                "elastictranscoder:*Job",
                "elastictranscoder:*Preset",
                "s3:ListAllMyBuckets",
                "s3:ListBucket",
                "iam:ListRoles",
                "sns:ListTopics"
            ],
            "Effect": "Allow",
            "Resource": "*"
            }
      

        ]
  }
  EOF
}

resource "aws_iam_role" "choirlessTranscoderRole" {
  name = "choirlessTranscoderRole-${terraform.workspace}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "elastictranscoder.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "elasticTranscoderPolicy" {

   role = aws_iam_role.choirlessTranscoderRole.name
   policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonElasticTranscoderRole"
}
