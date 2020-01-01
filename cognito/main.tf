resource "aws_cognito_user_pool" "pool" {
  name = "mypool"

  alias_attributes = []


}

resource "aws_cognito_user_pool_domain" "main" {
  domain       = "addsdrsderera"
  user_pool_id = "${aws_cognito_user_pool.pool.id}"
}