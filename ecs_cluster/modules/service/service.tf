resource "aws_alb_target_group" "service_target_group" {
    name = "my-alb-group"
    port = 80
    protocol = "HTTP"
    vpc_id = "${var.VpcId}"
}

resource "aws_alb_listener" "front_end" {
    load_balancer_arn = "${var.LoadBallancerId}"
    port = "80"
    protocol = "HTTP"

    default_action {
        target_group_arn = "${aws_alb_target_group.service_target_group.id}"
        type = "forward"
    }
}

resource "aws_ecs_service" "test-ecs-service" {
    name = "test-vz-service"
    cluster = "${var.ClusterId}"
    task_definition = "${aws_ecs_task_definition.task_definition.family}:${max("${aws_ecs_task_definition.task_definition.revision}", "${data.aws_ecs_task_definition.existing_task_definition.revision}")}"
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