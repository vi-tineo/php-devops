variable "subnet_ids" {
  description = "Lista de IDs das subnets privadas para o cluster EKS"
  type        = list(string)
}

variable "cluster_role_arn" {
  description = "ARN da role usada pelo cluster EKS"
  type        = string
}

variable "fargate_role_arn" {
  description = "ARN da role usada pelo Fargate Profile"
  type        = string
}

variable "cluster_version" {
  description = "Versão do cluster EKS"
  type        = string
}

variable "cluster_role_dependency" {
  description = "Dependência para garantir que a role do cluster esteja pronta"
  type        = any
}

variable "fargate_role_dependency" {
  description = "Dependência para garantir que a role do Fargate esteja pronta"
  type        = any
}
