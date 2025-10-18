output "vpc_id" {
  description = "ID da VPC criada"
  value       = aws_vpc.eks_vpc.id
}

output "private_subnet_ids" {
  description = "Lista de IDs das subnets privadas"
  value       = [
    aws_subnet.private1.id,
    aws_subnet.private2.id
  ]
}

output "public_subnet_ids" {
  description = "Lista de IDs das subnets públicas"
  value       = [
    aws_subnet.public1.id,
    aws_subnet.public2.id
  ]
}
