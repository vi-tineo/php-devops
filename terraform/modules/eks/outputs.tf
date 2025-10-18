output "cluster_name" {
  description = "Nome do cluster EKS"
  value       = aws_eks_cluster.eks.name
}

output "cluster_endpoint" {
  description = "Endpoint do cluster EKS"
  value       = aws_eks_cluster.eks.endpoint
}

output "cluster_ca" {
  description = "Certificado da autoridade do cluster EKS (base64)"
  value       = aws_eks_cluster.eks.certificate_authority[0].data
}
