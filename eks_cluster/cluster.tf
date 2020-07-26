data "aws_vpc" "default" {
  	  default = true
}

data "aws_subnet_ids" "default_subnets_ids" {
  vpc_id = "${data.aws_vpc.default.id}"
}

data "aws_subnet" "default_subnets" {
  count = "${length(data.aws_subnet_ids.default_subnets_ids.ids)}"
  id    = "${data.aws_subnet_ids.default_subnets_ids.ids[count.index]}"
}

resource "aws_eks_cluster" "cluster" {
  name     = "${var.ClusterName}"
  role_arn = "${aws_iam_role.eks-cluster-role.arn}"

  vpc_config {
    subnet_ids = ["${data.aws_subnet.default_subnets.*.id}"]
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    "aws_iam_role_policy_attachment.eks-cluster-policy",
    "aws_iam_role_policy_attachment.eks-service-policy",
  ]
}

output "endpoint" {
  value = "${aws_eks_cluster.cluster.endpoint}"
}

output "kubeconfig-certificate-authority-data" {
  value = "${aws_eks_cluster.cluster.certificate_authority.0.data}"
}