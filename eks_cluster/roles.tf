# EKS cluster Role
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


# Node Group Role

data "aws_iam_policy_document" "eks-node-group-policy" {
    statement {
        actions = ["sts:AssumeRole"]

        principals {
            type = "Service"
            identifiers = ["ec2.amazonaws.com"]
        }
    }
}

resource "aws_iam_role" "eks-node-group-role" {
    name = "eks-node-group-role"
    path = "/"
    assume_role_policy = "${data.aws_iam_policy_document.eks-node-group-policy.json}"
}

resource "aws_iam_role_policy_attachment" "example-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = "${aws_iam_role.eks-node-group-role.name}"
}

resource "aws_iam_role_policy_attachment" "example-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = "${aws_iam_role.eks-node-group-role.name}"
}

resource "aws_iam_role_policy_attachment" "example-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = "${aws_iam_role.eks-node-group-role.name}"
}