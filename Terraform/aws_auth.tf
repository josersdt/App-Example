#########################################
# aws_auth.tf
#########################################
resource "kubernetes_config_map" "aws_auth" {
  # Asegura que el clúster EKS esté creado antes de aplicar este recurso
  depends_on = [
    module.eks, kubernetes_namespace.mern
  ]

  metadata {
    name      = "aws-auth"
    namespace = "mern"
  }

  data = {
    mapRoles = yamlencode([
      {
        rolearn  = "arn:aws:iam::625006984319:role/AWSReservedSSO_AWSAdministratorAccess_90386bec0051ffff"
        username = "admin-user"
        groups   = ["system:masters"]
      }
    ])
  }
}
