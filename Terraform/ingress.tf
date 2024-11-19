resource "kubernetes_ingress_v1" "test_app_ingress" {
  depends_on = [
    module.eks,
    helm_release.aws_load_balancer_controller  # o el recurso que instale tu ALB Controller
  ]

  metadata {
    name      = "mern-alb-dev"
    namespace = "mern"
    annotations = {
      "kubernetes.io/ingress.class"              = "alb"
      "alb.ingress.kubernetes.io/scheme"         = "internet-facing"
      "alb.ingress.kubernetes.io/listen-ports"   = "[{\"HTTP\":80}]"
      "alb.ingress.kubernetes.io/target-type"    = "ip"
      "alb.ingress.kubernetes.io/rewrite-target" = "/$2"
    }
  }
  spec {
    rule {
      http {
        path {
          path     = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "frontend"
              port {
                number = 3000
              }
            }
          }
        }    
        path {
          path     = "/backend"
          path_type = "Prefix"
          backend {
            service {
              name = "backend"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}
