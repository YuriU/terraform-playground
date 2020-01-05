# Service role configuration:

data "aws_iam_policy_document" "ecs_service_policy" {
    statement {
        actions = ["sts:AssumeRole"]

        principals {
            type = "Service"
            identifiers = ["ecs.amazonaws.com"]
        }
    }
}

resource "aws_iam_role" "ecs_service_role" {
    name = "${var.ServiceName}-service-role"
    path = "/"
    assume_role_policy = "${data.aws_iam_policy_document.ecs_service_policy.json}"
}

resource "aws_iam_role_policy_attachment" "ecs_service_role_attachment" {
    role = "${aws_iam_role.ecs_service_role.name}"
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}

#Autoscaling role configuration
data "aws_iam_policy_document" "ecs_autoscaling_policy" {
    statement {
        actions = ["sts:AssumeRole"]

        principals {
            type = "Service"
            identifiers = ["application-autoscaling.amazonaws.com"]
        }
    }
}

resource "aws_iam_role" "ecs_autoscaling_role" {
    name = "${var.ServiceName}-autoscaling-role"
    path = "/"
    assume_role_policy = "${data.aws_iam_policy_document.ecs_autoscaling_policy.json}"
}

resource "aws_iam_role_policy_attachment" "ecs_autoscale" {
    role = "${aws_iam_role.ecs_autoscaling_role.name}"
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}

resource "aws_iam_role_policy_attachment" "ecs_cloudwatch" {
    role = "${aws_iam_role.ecs_autoscaling_role.name}"
    policy_arn = "arn:aws:iam::aws:policy/CloudWatchReadOnlyAccess"
}