resource "aws_cognito_user_pool" "pool" {
  name = "${var.Name}"

  alias_attributes = []
}

resource "aws_cognito_user_pool_domain" "main" {
  domain       = "${var.Domain}"
  user_pool_id = "${aws_cognito_user_pool.pool.id}"
}

resource "aws_cognito_identity_provider" "google_provider" {
  user_pool_id  = "${aws_cognito_user_pool.pool.id}"
  provider_name = "Google"
  provider_type = "Google"

  provider_details {
    authorize_scopes = "profile openid email"
    client_id        = "${var.GoogleAppId}"
    client_secret    = "${var.GoogleAppSecret}"
  }

  attribute_mapping {
    email    = "email"
    username = "sub"
  }
}

resource "aws_cognito_user_pool_client" "client" {
  name = "${var.ClientName}"

  supported_identity_providers = ["Google"]
  callback_urls     = ["http://localhost:8080/"]
  logout_urls       = ["http://localhost:8080/"]

  user_pool_id      = "${aws_cognito_user_pool.pool.id}"
}