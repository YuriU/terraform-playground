resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = 15
  min_capacity       = 3
  resource_id        = "service/${var.ClusterName}/${var.ServiceName}"
  role_arn           = "${aws_iam_role.ecs-autoscaling-role.arn}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

   depends_on = [
      "aws_ecs_service.service"
    ]
}


# 
# ScaleUP section
#

resource "aws_appautoscaling_policy" "scale_up" {
  name               = "scale-up"
  policy_type        = "StepScaling"
  resource_id        = "${aws_appautoscaling_target.ecs_target.resource_id}"
  scalable_dimension = "${aws_appautoscaling_target.ecs_target.scalable_dimension}"
  service_namespace  = "${aws_appautoscaling_target.ecs_target.service_namespace}"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_lower_bound = 0
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


# 
# ScaleDown section
#

resource "aws_appautoscaling_policy" "scale_down" {
  name               = "scale-down"
  policy_type        = "StepScaling"
  resource_id        = "${aws_appautoscaling_target.ecs_target.resource_id}"
  scalable_dimension = "${aws_appautoscaling_target.ecs_target.scalable_dimension}"
  service_namespace  = "${aws_appautoscaling_target.ecs_target.service_namespace}"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = -1
    }
  }
}

resource "aws_cloudwatch_metric_alarm" "service_scale_down_alarm" {
  alarm_name          = "${var.ServiceName}_ScaleDown"
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

  alarm_description = "Service needs more instances"
  alarm_actions     = ["${aws_appautoscaling_policy.scale_down.arn}"]
}