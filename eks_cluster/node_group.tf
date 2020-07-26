resource "aws_eks_node_group" "node_group" {
  cluster_name    = "${aws_eks_cluster.cluster.name}"
  node_group_name = "node_group"
  node_role_arn   = "${aws_iam_role.eks-node-group-role.arn}"
  subnet_ids      = ["${data.aws_subnet.default_subnets.*.id}"]

  scaling_config {
    desired_size = 2
    max_size     = 2
    min_size     = 2
  }

  instance_types = [
    "${var.InstanceSize}"
  ]

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    "aws_iam_role_policy_attachment.example-AmazonEKSWorkerNodePolicy",
    "aws_iam_role_policy_attachment.example-AmazonEKS_CNI_Policy",
    "aws_iam_role_policy_attachment.example-AmazonEC2ContainerRegistryReadOnly",
  ]
}