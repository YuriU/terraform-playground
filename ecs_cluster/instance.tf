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

    //security_groups = ["${aws_security_group.allow_all.id}"]
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
    max_size = "2"
    min_size = "1"
    desired_capacity = "1"

    vpc_zone_identifier =  ["${data.aws_subnet.example.*.id}"]
    launch_configuration = "${aws_launch_configuration.ecs-launch-configuration.name}"
    health_check_type = "ELB"

    tag {
        key = "Name"
        value = "ECS-myecscluster"
        propagate_at_launch = true
    }
}



output "subnets" {
    value = "${data.aws_subnet.example.*.id}"
}