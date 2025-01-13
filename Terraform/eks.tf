############################
# eks.tf
############################
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = "1.31"
  
  # VPC donde se ubica el EKS
  vpc_id    = module.vpc.vpc_id
  
  # Subnets en las que se crea el control plane
  subnet_ids = module.vpc.private_subnets

  # Configuración de acceso público y privado al endpoint del control plane
  cluster_endpoint_private_access = true  # Habilita acceso privado al control plane
  cluster_endpoint_public_access  = true  # Habilita acceso público al control plane
  cluster_endpoint_public_access_cidrs = ["190.66.210.186/32"] # IPs permitidas para acceso público

  enable_cluster_creator_admin_permissions = true 

  # Configuración de grupos de nodos administrados
  eks_managed_node_groups = {
    default = {
      desired_capacity = 2
      max_capacity     = 3
      min_capacity     = 1
      instance_types   = ["t3.medium"]

      # Subnets para los nodos (worker nodes)
      subnet_ids = module.vpc.private_subnets
      
    }
  }

}

module "eks_auth" {
  source  = "terraform-aws-modules/eks/aws//modules/aws-auth"
  version = "~> 20.0"

  manage_aws_auth_configmap = true

  aws_auth_roles = [
    {
      rolearn  = "arn:aws:iam::625006984319:role/aws-reserved/sso.amazonaws.com/AWSReservedSSO_AWSAdministratorAccess_90386bec0051ffff"
      username = "role_admin"
      groups   = ["system:masters"]
    },
  ]
}