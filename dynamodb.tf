// DynamoDB choirless table
resource "aws_dynamodb_table" "choirlessDB" {
  name = "choirless-${terraform.workspace}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "pk"
  range_key = "sk"

  attribute {
   name = "pk"
   type = "S"
  }
  attribute {
   name = "sk"
   type = "S"
  }

  attribute {
   name = "GSI1PK"
   type = "S"
  }
  attribute {
   name = "GSI1SK"
   type = "S"
  }

  global_secondary_index {
    name = "gsi1"
    hash_key = "GSI1PK"
    range_key = "GSI1SK"
    projection_type = "ALL"
  }

}
