provider "aws" {
  region = "us-east-1"
}

provider "kubernetes" {
  host                   = aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.eks.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.auth.token
}

data "aws_eks_cluster_auth" "auth" {
  name = aws_eks_cluster.eks.name
}

# VPC
resource "aws_vpc" "eks_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "eks-fargate-vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.eks_vpc.id
}

# Public Subnets
resource "aws_subnet" "public1" {
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "eks-public-subnet-1"
  }
}

resource "aws_subnet" "public2" {
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "eks-public-subnet-2"
  }
}

# Elastic IP for NAT
resource "aws_eip" "nat_eip" {}

# NAT Gateway
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public1.id
  depends_on    = [aws_internet_gateway.igw]
}

# Private Subnets
resource "aws_subnet" "private1" {
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false
  tags = {
    Name                                = "eks-private-subnet-1"
    "kubernetes.io/cluster/eks-fargate" = "shared"
  }
}

resource "aws_subnet" "private2" {
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = "10.0.4.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = false
  tags = {
    Name                                = "eks-private-subnet-2"
    "kubernetes.io/cluster/eks-fargate" = "shared"
  }
}

# Route Tables
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.eks_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.eks_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
}

# Route Table Associations
resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public2" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private1" {
  subnet_id      = aws_subnet.private1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private2" {
  subnet_id      = aws_subnet.private2.id
  route_table_id = aws_route_table.private.id
}

# IAM Role for Cluster
resource "aws_iam_role" "eks_cluster_role" {
  name = "eksClusterRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# IAM Role for Fargate
resource "aws_iam_role" "fargate_profile_role" {
  name = "eksFargateProfileRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "eks-fargate-pods.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "fargate_policy" {
  role       = aws_iam_role.fargate_profile_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
}

# EKS Cluster
resource "aws_eks_cluster" "eks" {
  name     = "eks-fargate"
  role_arn = aws_iam_role.eks_cluster_role.arn
  version  = "1.28"

  vpc_config {
    subnet_ids = [aws_subnet.private1.id, aws_subnet.private2.id]
  }

  depends_on = [aws_iam_role_policy_attachment.eks_cluster_policy]
}

# Fargate Profile
resource "aws_eks_fargate_profile" "default" {
  cluster_name           = aws_eks_cluster.eks.name
  fargate_profile_name   = "default"
  pod_execution_role_arn = aws_iam_role.fargate_profile_role.arn
  subnet_ids             = [aws_subnet.private1.id, aws_subnet.private2.id]

  selector {
    namespace = "default"
  }

  depends_on = [aws_iam_role_policy_attachment.fargate_policy]
}

# NGINX Deployment
resource "kubernetes_deployment" "demo_app" {
  metadata {
    name      = "demo-app"
    namespace = "default"
    labels = {
      app = "demo-app"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "demo-app"
      }
    }

    template {
      metadata {
        labels = {
          app = "demo-app"
        }
      }

      spec {
        container {
          name  = "demo"
          image = "nginx:latest"

          port {
            container_port = 80
          }
        }
      }
    }
  }

  depends_on = [aws_eks_fargate_profile.default]
}

# LoadBalancer Service
resource "kubernetes_service" "demo_lb" {
  metadata {
    name      = "demo-lb"
    namespace = "default"
  }

  spec {
    selector = {
      app = "demo-app"
    }

    type = "LoadBalancer"

    port {
      port        = 80
      target_port = 80
    }
  }

  depends_on = [kubernetes_deployment.demo_app]
}
