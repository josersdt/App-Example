resource "kubernetes_secret" "db_credentials" {
  depends_on = [module.eks, kubernetes_namespace.mern]
  metadata {
    name      = "db-credentials"
    namespace = "mern"
  }
  data = {
    password = base64encode("bXlzcWwxMjM=") #mysql123
    database = base64encode("c2Nob29s") #school
    host     = base64encode("ZGF0YWJhc2U=") #database
    user     = base64encode("cm9vdA==") #root
  }
  type = "Opaque"
}
