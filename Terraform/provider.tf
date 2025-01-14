############################
# provider.tf
############################

# 1) Provider de AWS
provider "aws" {
  region = var.aws_region
}

# 2) Datos del cluster EKS, necesarios para el provider kubernetes
data "aws_eks_cluster" "cluster" {
  depends_on = [module.eks]
  name = module.eks.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  depends_on = [module.eks]
  name = module.eks.cluster_name
}

# 3) Provider de Kubernetes
provider "kubernetes" {
  
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  
}

