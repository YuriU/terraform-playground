resource "aws_cognito_user_pool" "pool" {
  name = "mypool"

  alias_attributes = []


}

resource "aws_cognito_user_pool_domain" "main" {
  domain       = "addsdrsderera"
  user_pool_id = "${aws_cognito_user_pool.pool.id}"
}

resource "aws_cognito_identity_provider" "google_provider" {
  user_pool_id  = "${aws_cognito_user_pool.pool.id}"
  provider_name = "Google"
  provider_type = "Google"

  provider_details = {
    authorize_scopes = "profile openid email"
    client_id        = "${var.GoogleAppId}"
    client_secret    = "${var.GoogleAppSecret}"
  }

  attribute_mapping = {
    email    = "email"
    username = "sub"
  }
}