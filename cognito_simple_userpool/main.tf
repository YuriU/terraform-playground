resource "aws_cognito_user_pool" "pool" {
  name = "${var.Name}"

  alias_attributes = []
}

resource "aws_cognito_user_pool_client" "client" {
  name = "${var.ClientName}"

  generate_secret     = true
  explicit_auth_flows = []

  allowed_oauth_flows = ["implicit"]
  allowed_oauth_scopes = [ "email", "openid", "profile" ]

  allowed_oauth_flows_user_pool_client = true

  callback_urls     = ["http://localhost:8080/"]
  logout_urls       = ["http://localhost:8080/"]

  user_pool_id      = "${aws_cognito_user_pool.pool.id}"
}