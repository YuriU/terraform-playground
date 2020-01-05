data "aws_ecs_cluster" "cluster" {
  cluster_name = "${var.ClusterName}"
}

resource "aws_alb_target_group" "service_target_group" {
    name = "ECS-${var.ServiceName}-TargetGroup"
    port = 80
    protocol = "HTTP"
    vpc_id = "${var.VpcId}"

    deregistration_delay = 20 // Seconds before drop instance
}

resource "aws_lb_listener_rule" "host_based_routing" {
  listener_arn = "${var.ListenerArn}"
  priority     = 99

  action {
    type             = "forward"
    target_group_arn = "${aws_alb_target_group.service_target_group.arn}"
  }

  condition {
    path_pattern {
      values = ["/apache/*", "/apache", "/index.html"]
    }
  }
}

resource "aws_ecs_service" "service" {
    name = "${var.ServiceName}"
    cluster = "${data.aws_ecs_cluster.cluster.arn}"
    task_definition = "${aws_ecs_task_definition.task_definition.family}:${max("${aws_ecs_task_definition.task_definition.revision}", "${data.aws_ecs_task_definition.existing_task_definition.revision}")}"
    desired_count = "${var.MinCount}"
    iam_role = "${aws_iam_role.ecs-service-role.name}"

    load_balancer {
        target_group_arn = "${aws_alb_target_group.service_target_group.id}"
        container_name = "apache"
        container_port = "8080"
    }

    depends_on = [
      "aws_lb_listener_rule.host_based_routing"
    ]

    lifecycle {
      ignore_changes = ["desired_count"]
    }
}