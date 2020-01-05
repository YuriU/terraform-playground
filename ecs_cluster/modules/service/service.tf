data "aws_ecs_cluster" "cluster" {
  cluster_name = "${var.ClusterName}"
}

resource "aws_alb_target_group" "service_target_group" {
    name = "ECS-${var.ServiceName}-TargetGroup"
    port = 80
    protocol = "HTTP"
    vpc_id = "${var.VpcId}"
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
    desired_count = "${var.DesiredCount}"
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





resource "aws_cloudwatch_metric_alarm" "service_scale_in_alarm" {
  alarm_name          = "${var.ServiceName}_ScaleIn"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "MyTestMetric"
  namespace           = "TEST/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "30"

  dimensions {
    ServiceName = "${var.ServiceName}"
  }

  alarm_description = "Service can free some instances"
  //alarm_actions     = ["${aws_autoscaling_policy.auto_scaling_policy_up.arn}"]
}

resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = 15
  min_capacity       = 3
  resource_id        = "service/${var.ClusterName}/${var.ServiceName}"
  role_arn           = "arn:aws:iam::039810988692:role/apache-autoscaling-role"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

   depends_on = [
      "aws_ecs_service.service"
    ]
}

resource "aws_appautoscaling_policy" "scale_up" {
  name               = "scale-up"
  policy_type        = "StepScaling"
  resource_id        = "${aws_appautoscaling_target.ecs_target.resource_id}"
  scalable_dimension = "${aws_appautoscaling_target.ecs_target.scalable_dimension}"
  service_namespace  = "${aws_appautoscaling_target.ecs_target.service_namespace}"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Maximum"

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = 1
    }
  }
}

resource "aws_cloudwatch_metric_alarm" "service_scale_out_alarm" {
  alarm_name          = "${var.ServiceName}_ScaleOut"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "MyTestMetric"
  namespace           = "TEST/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "70"

  dimensions {
    ServiceName = "${var.ServiceName}"
  }

  alarm_description = "Service needs more instances"
  alarm_actions     = ["${aws_appautoscaling_policy.scale_up.arn}"]
}