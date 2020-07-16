data "aws_iam_policy_document" "eks-instance-policy" {
    statement {
        actions = ["sts:AssumeRole"]

        principals {
            type = "Service"
            identifiers = ["eks.amazonaws.com"]
        }
    }
}

resource "aws_iam_role" "eks-cluster-role" {
    name = "eks-cluster-role"
    path = "/"
    assume_role_policy = "${data.aws_iam_policy_document.eks-instance-policy.json}"
}

resource "aws_iam_role_policy_attachment" "eks-cluster-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = "${aws_iam_role.eks-cluster-role.name}"
}

resource "aws_iam_role_policy_attachment" "eks-service-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = "${aws_iam_role.eks-cluster-role.name}"
}