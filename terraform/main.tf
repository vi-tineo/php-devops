data "aws_eks_cluster_auth" "auth" {
  name = module.eks.cluster_name
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_ca)
  token                  = data.aws_eks_cluster_auth.auth.token
}

module "network" {
  source = "./modules/network"

  region                = var.region
  vpc_cidr              = var.vpc_cidr
  public_subnet1_cidr   = var.public_subnet1_cidr
  public_subnet2_cidr   = var.public_subnet2_cidr
  private_subnet1_cidr  = var.private_subnet1_cidr
  private_subnet2_cidr  = var.private_subnet2_cidr
  az1                   = var.az1
  az2                   = var.az2
}

module "iam" {
  source = "./modules/iam"
}

module "eks" {
  source              = "./modules/eks"
  subnet_ids          = module.network.private_subnet_ids
  cluster_role_arn    = module.iam.cluster_role_arn
  fargate_role_arn    = module.iam.fargate_role_arn
  cluster_version     = var.cluster_version
}

module "k8s" {
  source           = "./modules/k8s"
  cluster_endpoint = module.eks.cluster_endpoint
  cluster_ca       = module.eks.cluster_ca
  cluster_token    = data.aws_eks_cluster_auth.auth.token
}
