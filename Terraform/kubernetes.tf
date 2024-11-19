############################################
# kubernetes.tf
############################################

########################
# FRONTEND
########################
resource "kubernetes_deployment" "frontend" {
  depends_on = [
    kubernetes_namespace.mern,
    kubernetes_secret.db_credentials,
    kubernetes_persistent_volume_claim.db_pvc
  ]
  metadata {
    name      = "frontend-deployment"
    namespace = "mern"
    labels = {
      role = "frontend"
      env = "dev"
    }
  }
  spec {
    replicas = 2
    selector {
      match_labels = {
        role = "frontend"
      }
    }
    template {
      metadata {
        labels = {
          role = "frontend"
        }
      }
      spec {
        container {
          name  = "frontend"
          image = "${aws_ecr_repository.frontend_repo.repository_url}:${var.docker_image_tag}"
          port {
            container_port = 3000
          }
          env {
            name = "REACT_APP_API_BASE_URL"
            value = "http://<your-domain-name>/backend"
          }
          env {
            name = "NODE_OPTIONS"
            value = "--openssl-legacy-provider"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "frontend_svc" {
  depends_on = [
    kubernetes_namespace.mern,
    kubernetes_secret.db_credentials,
    kubernetes_persistent_volume_claim.db_pvc
  ]
  metadata {
    name = "frontend-service"
    namespace = "mern"
  }
  spec {
    selector = {
      role = "frontend"
    }
    type = "ClusterIP"
    port {
      port        = 3000
      protocol    = "TCP"
    }
  }
}

########################
# BACKEND
########################
resource "kubernetes_deployment" "backend" {
  depends_on = [
    kubernetes_namespace.mern,
    kubernetes_secret.db_credentials,
    kubernetes_persistent_volume_claim.db_pvc
  ]
  metadata {
    name      = "backend-deployment"
    namespace = "mern"
    labels = {
      role = "backend"
      env = "dev"
    }
  }
  spec {
    replicas = 2
    selector {
      match_labels = {
        app = "backend"
      }
    }
    template {
      metadata {
        labels = {
          app = "backend"
        }
      }
      spec {
        container {
          name  = "backend"
          image = "${aws_ecr_repository.backend_repo.repository_url}:${var.docker_image_tag}"
          port {
            container_port = 3500
          }
          env {
            name = "host"
            value_from {
              secret_key_ref {
                name = "db-credentials"
                key  = "host"
              }           
            }
          }
          env {
            name = "user"
            value_from {
              secret_key_ref {
                name = "db-credentials"
                key  = "user"
              }           
            }
          }
          env {
            name = "password"
            value_from {
              secret_key_ref {
                name = "db-credentials"
                key  = "password"
              }           
            }
          }
          env {
            name = "database"
            value_from {
              secret_key_ref {
                name = "db-credentials"
                key  = "database"
              }           
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "backend_svc" {
  depends_on = [
    kubernetes_namespace.mern,
    kubernetes_secret.db_credentials,
    kubernetes_persistent_volume_claim.db_pvc
  ]
  metadata {
    name = "backend"
    namespace = "mern"
  }
  spec {
    selector = {
      role = "backend"
    }
    type = "ClusterIP" # o LoadBalancer si lo deseas expuesto
    port {
      name        = "backend-port"
      port        = 80
      target_port = 3500
    }
  }
}

########################
# DATABASE
########################
resource "kubernetes_deployment" "database" {
  depends_on = [
    kubernetes_namespace.mern,
    kubernetes_secret.db_credentials,
    kubernetes_persistent_volume_claim.db_pvc
  ]
  metadata {
    name      = "database"
    namespace = "mern"
    labels = {
      role = "database"
      env = "dev"
    }
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        role = "database"
      }
    }
    template {
      metadata {
        labels = {
          role = "database"
        }
      }
      spec {
        container {
          name  = "database"
          image = "${aws_ecr_repository.database_repo.repository_url}:${var.docker_image_tag}"
          port {
            container_port = 3306
          }
          env {
            name = "MYSQL_ROOT_PASSWORD"
            value_from {
              secret_key_ref {
                name = "db-credentials"
                key  = "password"
              }           
            }
          }
          env {
            name = "MYSQL_DATABASE"
            value_from {
              secret_key_ref {
                name = "db-credentials"
                key  = "database"
              }           
            }
          }
          volume_mount {
            name = "db-storage"
            mount_path = "/var/lib/mysql"          
          }
        }
        volume {
          name  = "db-storage"
          persistent_volume_claim {
            claim_name = "db-pvc"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "database_svc" {
  depends_on = [
    kubernetes_namespace.mern,
    kubernetes_secret.db_credentials,
    kubernetes_persistent_volume_claim.db_pvc
  ]
  metadata {
    name = "database"
    namespace = "mern"
  }
  spec {
    selector = {
      role = "database"
    }
    type = "ClusterIP"
    port {
      port        = 3306
      protocol    = "TCP"
    }
  }
}
