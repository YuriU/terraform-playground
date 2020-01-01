resource "aws_cognito_user_pool" "pool" {
  name = "mypool"

  username_attributes = ["email"]
}