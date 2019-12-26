resource "aws_alb_target_group" "service_target_group" {
    name = "my-alb-group"
    port = 80
    protocol = "HTTP"
    vpc_id = "${data.aws_vpc.default.id}"
}

resource "aws_alb_listener" "front_end" {
    load_balancer_arn = "${aws_alb.main.id}"
    port = "80"
    protocol = "HTTP"

    default_action {
        target_group_arn = "${aws_alb_target_group.service_target_group.id}"
        type = "forward"
    }
}

resource "aws_ecs_service" "test-ecs-service" {
    name = "test-vz-service"
    cluster = "${module.cluster.ClusterId}"
    task_definition = "${aws_ecs_task_definition.test.family}:${max("${aws_ecs_task_definition.test.revision}", "${data.aws_ecs_task_definition.test.revision}")}"
    desired_count = 1
    iam_role = "${aws_iam_role.ecs-service-role.name}"

    load_balancer {
        target_group_arn = "${aws_alb_target_group.service_target_group.id}"
        container_name = "apache"
        container_port = "8080"
    }

    depends_on = [
        #"aws_iam_role_policy.ecs-service",
        "aws_alb_listener.front_end",
    ]
}