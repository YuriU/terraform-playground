# Service role configuration:

data "aws_iam_policy_document" "ecs-service-policy" {
    statement {
        actions = ["sts:AssumeRole"]

        principals {
            type = "Service"
            identifiers = ["ecs.amazonaws.com"]
        }
    }
}

resource "aws_iam_role" "ecs-service-role" {
    name = "${var.ServiceName}-service-role"
    path = "/"
    assume_role_policy = "${data.aws_iam_policy_document.ecs-service-policy.json}"
}

resource "aws_iam_role_policy_attachment" "ecs-service-role-attachment" {
    role = "${aws_iam_role.ecs-service-role.name}"
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}

#Autoscaling role configuration
data "aws_iam_policy_document" "ecs-autoscaling-policy" {
    statement {
        actions = ["sts:AssumeRole"]

        principals {
            type = "Service"
            identifiers = ["application-autoscaling.amazonaws.com"]
        }
    }
}

resource "aws_iam_role" "ecs-autoscaling-role" {
    name = "${var.ServiceName}-autoscaling-role"
    path = "/"
    assume_role_policy = "${data.aws_iam_policy_document.ecs-autoscaling-policy.json}"
}

resource "aws_iam_role_policy_attachment" "ecs_autoscale" {
    role = "${aws_iam_role.ecs-autoscaling-role.name}"
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}

resource "aws_iam_role_policy_attachment" "ecs_cloudwatch" {
    role = "${aws_iam_role.ecs-autoscaling-role.name}"
    policy_arn = "arn:aws:iam::aws:policy/CloudWatchReadOnlyAccess"
}