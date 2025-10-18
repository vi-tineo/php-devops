resource "aws_eks_cluster" "eks" {
  name     = "eks-fargate"
  role_arn = var.cluster_role_arn
  version  = var.cluster_version

  vpc_config {
    subnet_ids = var.subnet_ids
  }

  depends_on = [var.cluster_role_dependency]
}

resource "aws_eks_fargate_profile" "default" {
  cluster_name           = aws_eks_cluster.eks.name
  fargate_profile_name   = "default"
  pod_execution_role_arn = var.fargate_role_arn
  subnet_ids             = var.subnet_ids

  selector {
    namespace = "default"
  }

  depends_on = [var.fargate_role_dependency]
}
