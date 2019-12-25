resource "aws_ecs_cluster" "cluster" {
	count = 1
	name = "${var.ClusterName}"
}