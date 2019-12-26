module "cluster" {
    source                      = "./modules/cluster"
    ClusterName                 = "${var.ClusterName}"
    InstancesCount              = "${var.InstancesCount}"
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
    ClusterId                   = "${module.cluster.ClusterId}"
}