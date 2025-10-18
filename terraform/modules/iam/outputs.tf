output "cluster_role_arn" {
  description = "ARN da role usada pelo cluster EKS"
  value       = aws_iam_role.eks_cluster_role.arn
}

output "fargate_role_arn" {
  description = "ARN da role usada pelo Fargate Profile"
  value       = aws_iam_role.fargate_profile_role.arn
}
