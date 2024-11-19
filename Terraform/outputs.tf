############################
# outputs.tf
############################

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "oidc_provider_arn" {
  description = "The ARN of the OIDC Provider if `enable_irsa = true`"
  value       = module.eks.oidc_provider_arn
}

output "frontend_load_balancer_dns" {
  value = kubernetes_service.frontend_svc.status[0].load_balancer[0].ingress[0].hostname
}
