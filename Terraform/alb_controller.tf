##################################################
# alb_controller.tf (parte 1/3)
##################################################

resource "aws_iam_policy" "alb_ingress_controller_policy" {
  name        = "alb-ingress-controller-policy"
  description = "Permissions for AWS Load Balancer Controller"
  policy      = file("${path.module}/Policies/alb-ingress-controller.json")
}

data "aws_iam_policy_document" "alb_ingress_controller_assume_role" {
  depends_on = [module.eks]
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Federated"
      identifiers = [module.eks.oidc_provider_arn]
    }
    condition {
      test     = "StringEquals"
      # Reemplaza <namespace> y <serviceAccountName> si usas otros
      variable = "${replace(data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
    }
  }
}

resource "aws_iam_role" "alb_ingress_controller" {
  name               = "alb-ingress-controller-role"
  assume_role_policy = data.aws_iam_policy_document.alb_ingress_controller_assume_role.json
}

resource "aws_iam_role_policy_attachment" "alb_ingress_controller_attachment" {
  role       = aws_iam_role.alb_ingress_controller.name
  policy_arn = aws_iam_policy.alb_ingress_controller_policy.arn
}

resource "kubernetes_service_account" "alb_ingress_sa" {
  depends_on = [kubernetes_namespace.mern]
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "mern"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.alb_ingress_controller.arn
    }
  }
}

resource "helm_release" "aws_load_balancer_controller" {
  depends_on = [module.eks]
  name            = "aws-load-balancer-controller"
  repository      = "https://aws.github.io/eks-charts"
  chart           = "aws-load-balancer-controller"
  version         = "1.11.0"              # Ajusta a la versión estable
  namespace       = "mern"

  # 1) Desactivamos la creación automática del SA para usar el nuestro
  set {
    name  = "serviceAccount.create"
    value = "false"
  }
  # 2) Indicamos cuál serviceAccount usar
  set {
    name  = "serviceAccount.name"
    value = kubernetes_service_account.alb_ingress_sa.metadata[0].name
  }

  # 3) Nombre del cluster EKS
  set {
    name  = "cluster_name"
    value = module.eks.cluster_name
  }

  # 4) Región AWS
  set {
    name  = "region"
    value = var.aws_region
  }

  # 5) VPC ID (para que sepa dónde crear ALBs)
  set {
    name  = "vpc_id"
    value = module.vpc.vpc_id
  }
  
  depends_on = [
    kubernetes_service_account.alb_ingress_sa,
    # Aseguramos que se cree el SA antes
    # y el role/policy
  ]
}
