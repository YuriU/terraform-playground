output "UserPoolId" {
	value = "${aws_cognito_user_pool.pool.id}"
}

output "UserPoolArn" {
	value = "${aws_cognito_user_pool.pool.arn}"
}