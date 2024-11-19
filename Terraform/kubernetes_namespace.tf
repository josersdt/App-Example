resource "kubernetes_namespace" "mern" {
  depends_on = [module.eks]
  metadata {
    name = "mern"
    labels = {
      env = "dev"
    }
  }
}
