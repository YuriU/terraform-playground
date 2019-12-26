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
    max_size = "${var.InstancesCount}"
    min_size = "${var.InstancesCount}"
    desired_capacity = "${var.InstancesCount}"

    vpc_zone_identifier =  ["${var.SubnetIds}"]
    launch_configuration = "${aws_launch_configuration.ecs-launch-configuration.name}"
    health_check_type = "ELB"

    tag {
        key = "Name"
        value = "ECS-${var.ClusterName}"
        propagate_at_launch = true
    }
}