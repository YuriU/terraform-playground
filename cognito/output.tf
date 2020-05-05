data "aws_region" "current" {}

output "Region" {
  value = "${data.aws_region.current.name}"
}

output "UserPoolId" {
	value = "${aws_cognito_user_pool.pool.id}"
}

output "UserPoolWebClientId" {
	value = "${aws_cognito_user_pool_client.client.id}"
}

output "UserPoolArn" {
	value = "${aws_cognito_user_pool.pool.arn}"
}

output "Domain" {
  value = "${aws_cognito_user_pool_domain.main.domain}.auth.${data.aws_region.current.name}.amazoncognito.com"
}

output "IdentityPoolId" {
	value = "${aws_cognito_identity_pool.main.id}"
}