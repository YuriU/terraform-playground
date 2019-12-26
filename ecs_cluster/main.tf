module "cluster" {
    source          = "./modules/cluster"
    ClusterName     = "${var.ClusterName}"
    InstancesCount  = "${var.InstancesCount}"
    InstanceType    = "${var.InstanceType}"
    InstanceAMI     = "${var.InstanceAMI}"
    SubnetIds       = ["${data.aws_subnet.example.*.id}"]
}