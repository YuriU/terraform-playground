module "cluster" {
    source                      = "./modules/cluster"
    ClusterName                 = "${var.ClusterName}"
    MinInstancesCount           = "${var.MinInstancesCount}"
    MaxInstancesCount           = "${var.MaxInstancesCount}"
    InstanceType                = "${var.InstanceType}"
    InstanceAMI                 = "${var.InstanceAMI}"
    SubnetIds                   = ["${data.aws_subnet.default_subnets.*.id}"]
    BalancerSecurityGroupId     = "${aws_security_group.web_server.id}"
}

module "apache" {
    source                      = "./modules/service"
    VpcId                       = "${data.aws_vpc.default.id}"
    LoadBallancerId             = "${aws_alb.main.id}"
    ServiceName                 = "apache"
    ClusterName                 = "${module.cluster.ClusterName}"
    ListenerArn                 = "${aws_alb_listener.front_end.arn}"
    MinCount                    = 3
    MaxCount                    = 15,

    AutoscalingMetricsName      = "MyTestMetric",
    AutoscalingMetricsNamespace = "TEST/ECS"
}