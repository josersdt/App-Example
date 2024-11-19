resource "kubernetes_persistent_volume_claim" "db_pvc" {
  depends_on = [module.eks, kubernetes_namespace.mern]
  metadata {
    name      = "db-pvc"
    namespace = "mern"
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "1Gi"
      }
    }
    storage_class_name = "gp3"
  }
}
