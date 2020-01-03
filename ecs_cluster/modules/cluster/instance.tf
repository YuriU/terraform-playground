resource "aws_security_group" "web_server" {
  name = "${var.ClusterName}Instance-SecurityGroup"

  egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "allow_balancer" {
  type = "ingress"
  protocol = "tcp"

  # Allowing all ports as ecs uses dynamic port mapping
  from_port = 0
  to_port = 65535

  security_group_id = "${aws_security_group.web_server.id}"
  source_security_group_id = "${var.BalancerSecurityGroupId}"
}

resource "aws_launch_configuration" "ecs-launch-configuration" {
    name = "${var.ClusterName}-launch-configuration"
    image_id = "${var.InstanceAMI}"
    instance_type = "${var.InstanceType}"

    iam_instance_profile = "${aws_iam_instance_profile.ecs-instance-profile.id}"

    root_block_device {
        volume_type = "standard"
        volume_size = 100
        delete_on_termination = true
    }

    lifecycle {
        create_before_destroy = true
    }

    security_groups = ["${aws_security_group.web_server.id}"]
    associate_public_ip_address = "false"

    #
    # register the cluster name with ecs-agent which will in turn coord
    # with the AWS api about the cluster
    #
    user_data = <<EOF
        #!/bin/bash
        echo "ECS_CLUSTER=${aws_ecs_cluster.cluster.name}" > /etc/ecs/ecs.config
    EOF
}

resource "aws_autoscaling_group" "ecs-autoscaling-group" {
    name = "${var.ClusterName}-autoscaling-group"
    max_size = "${var.MaxInstancesCount}"
    min_size = "${var.MinInstancesCount}"
    vpc_zone_identifier =  ["${var.SubnetIds}"]
    launch_configuration = "${aws_launch_configuration.ecs-launch-configuration.name}"
    health_check_type = "ELB"

    tag {
        key = "Name"
        value = "ECS-${var.ClusterName}"
        propagate_at_launch = true
    }
}

resource "aws_autoscaling_policy" "auto_scaling_policy_up" {
  name                   = "Scale Up by CPU Reservation"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 60
  autoscaling_group_name = "${aws_autoscaling_group.ecs-autoscaling-group.name}"
}

resource "aws_cloudwatch_metric_alarm" "cpu_scale_out_alarm" {
  alarm_name          = "${var.ClusterName}_OutOfReservedCpu"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUReservation"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "70"

  dimensions {
    ClusterName = "${var.ClusterName}"
  }

  alarm_description = "Cluster run out of CPUReservation"
  alarm_actions     = ["${aws_autoscaling_policy.auto_scaling_policy_up.arn}"]
}

resource "aws_autoscaling_policy" "auto_scaling_policy_down" {
  name                   = "Scale Down by CPU Reservation"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 60
  autoscaling_group_name = "${aws_autoscaling_group.ecs-autoscaling-group.name}"
}

resource "aws_cloudwatch_metric_alarm" "cpu_scale_in_alarm" {
  alarm_name          = "${var.ClusterName}_FreeReservedCpu"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUReservation"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "30"

  dimensions {
    ClusterName = "${var.ClusterName}"
  }

  alarm_description = "Cluster has too many CPUReservation"
  alarm_actions     = ["${aws_autoscaling_policy.auto_scaling_policy_down.arn}"]
}