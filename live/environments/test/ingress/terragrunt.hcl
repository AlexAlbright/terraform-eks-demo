include "root" {
  path   = find_in_parent_folders()
  expose = true
}

include "kubernetes_provider" {
  path   = find_in_parent_folders("kubernetes.hcl")
  expose = true
}

terraform {
  source = "../../../../components/ingress"
}

dependency "eks" {
  config_path = "../eks/"
}

dependency "argocd-init" {
  config_path = "../argocd-init"
}

inputs = {
  stack                              = "ingress"
  region                             = include.root.locals.region
  environment                        = include.root.locals.environment
  cluster_name                       = dependency.eks.outputs.cluster_name
  cluster_endpoint                   = dependency.eks.outputs.cluster_endpoint
  cluster_certificate_authority_data = dependency.eks.outputs.cluster_certificate_authority_data
  argocd_password                    = dependency.argocd-init.outputs.argocd_admin_setup_password
}
