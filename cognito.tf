resource "aws_cognito_user_pool" "choirless_cognito_pool" {
  name   = "choirless_cognito_pool"
  username_attributes = [ "email" ]
  password_policy  { 
    minimum_length                   = 8
    require_lowercase                = true
    require_numbers                  = true
    require_uppercase                = true
    temporary_password_validity_days = 7
    require_symbols                  = false
  }
  admin_create_user_config  {
    allow_admin_create_user_only = true
  }

  schema {
    name  = "family_name"
    required = true
    attribute_data_type = "String"
    mutable = true
    string_attribute_constraints {   # if it is a string
      min_length = 0   
      max_length = 100 
    }

  }

  schema {
    name  = "given_name"
    required = true
    attribute_data_type = "String"
    mutable = true
    string_attribute_constraints {   # if it is a string
      min_length = 0   
      max_length = 100 
    }

  }

}

output "cognitoUserPool"  {
  value = aws_cognito_user_pool.choirless_cognito_pool.id
}


resource "aws_cognito_user_group" "adminUsers" {
  name         = "adminUsers"
  user_pool_id = aws_cognito_user_pool.choirless_cognito_pool.id
  description  = "Admin Users"
  role_arn     = aws_iam_role.choirless_cognito_admin.arn
}

resource "aws_cognito_user_pool_client" "app-choirless" {
  name = "app-choirless"
  user_pool_id = aws_cognito_user_pool.choirless_cognito_pool.id
  callback_urls = terraform.workspace == "stage" ? ["http://localhost:8001"] :[ "https://mermelstein.co.uk"]
  logout_urls = terraform.workspace == "stage" ? ["http://localhost:8001"] : [ "https://mermelstein.co.uk"]
  // this means that Cognito itself generates an authorisation token. This is considered less secure than using 
  //the authorisation code grant flow... so maybe at some point that can be changed (but it requires having a back end that does the code exchange for an authorisation code 
  allowed_oauth_flows = [ "implicit" ]  
  // the email and opendid scopes have to go together according to the documentation
  allowed_oauth_scopes = [ "email","openid"]
  allowed_oauth_flows_user_pool_client = true
  supported_identity_providers = [ "COGNITO" ]

}

output "cognitoAppId"  {
  value = aws_cognito_user_pool_client.app-choirless.id
}

output "cognitoCallbackUrls" {
  value = aws_cognito_user_pool_client.app-choirless.callback_urls
}

output "cognitoLogoutUrls" {
  value = aws_cognito_user_pool_client.app-choirless.logout_urls
}

resource "aws_cognito_user_pool_domain" "choirless-domain" {
  domain       = "choirless"
  user_pool_id = aws_cognito_user_pool.choirless_cognito_pool.id
}

output "cognitoAppDomain"  {
  value = aws_cognito_user_pool_domain.choirless-domain.domain
}

//Create a federated identity pool
resource "aws_cognito_identity_pool" "choirless_id_pool" {
  identity_pool_name               = "choirless_pool"
  allow_unauthenticated_identities = false

  cognito_identity_providers {
  client_id               = aws_cognito_user_pool_client.app-choirless.id
  provider_name           = "cognito-idp.${data.aws_region.current.name}.amazonaws.com/${aws_cognito_user_pool.choirless_cognito_pool.id}"
  server_side_token_check = false
  }
}

output "cognitoIdentityPool"  {
  value = aws_cognito_identity_pool.choirless_id_pool.id
}

//This is the role that all authenticated users get by default. see the role attachment resource below
resource "aws_iam_role" "choirless_cognito_authenticated" {
  name = "choirless_cognito_authenticated"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "cognito-identity.amazonaws.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "cognito-identity.amazonaws.com:aud": "${aws_cognito_identity_pool.choirless_id_pool.id}"
        },
        "ForAnyValue:StringLike": {
          "cognito-identity.amazonaws.com:amr": "authenticated"
        }
      }
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "cognito_authenticated_policy" {
  name = "cognito_authenticated_policy"
  role = aws_iam_role.choirless_cognito_authenticated.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "mobileanalytics:PutEvents",
        "cognito-sync:*",
        "cognito-identity:*"
      ],
      "Resource": [
        "*"
      ]
    }    
  ]
}
EOF
}

//this is the role defines the permissions the admin has
resource "aws_iam_role" "choirless_cognito_admin" {
  name = "choirless_cognito_admin"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "cognito-identity.amazonaws.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "cognito-identity.amazonaws.com:aud": "${aws_cognito_identity_pool.choirless_id_pool.id}"
        },
        "ForAnyValue:StringLike": {
          "cognito-identity.amazonaws.com:amr": "authenticated"
        }
      }
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "cognito_admin_policy" {
  name = "cognito_admin_policy"
  role = aws_iam_role.choirless_cognito_admin.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "mobileanalytics:PutEvents",
        "cognito-sync:*",
        "cognito-identity:*"
      ],
      "Resource": [
        "*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
          "lambda:InvokeFunction"
      ],
      "Resource": [
          "${aws_lambda_function.lambda["getChoirSongParts"].arn}"
      ]
  }
  ]
}
EOF
}

//attach the role to the identity pool
resource "aws_cognito_identity_pool_roles_attachment" "choirless_id_pool_role_attachment" {
  identity_pool_id = aws_cognito_identity_pool.choirless_id_pool.id
  //the role mapping says that for authenticated users their permissions will be set by any roles attached to their user groups or, if the group has no roles,
  //it falls back onto the choirless_cognito_authenticated role
  role_mapping {
    identity_provider         = "cognito-idp.${data.aws_region.current.name}.amazonaws.com/${aws_cognito_user_pool.choirless_cognito_pool.id}:${aws_cognito_user_pool_client.app-choirless.id}"
    ambiguous_role_resolution = "AuthenticatedRole"
    type                      = "Token"
  }

  roles = {
    "authenticated" = aws_iam_role.choirless_cognito_authenticated.arn
  }
}
