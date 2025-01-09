resource "kubernetes_namespace" "mern" {
  depends_on = [module.eks, kubernetes_config_map.aws_auth]
  metadata {
    name = "mern"
    labels = {
      env = "dev"
    }
  }
}
