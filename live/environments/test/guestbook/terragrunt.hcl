include "root" {
  path = find_in_parent_folders()
  expose = true
}

include "kubernetes_provider" {
  path   = find_in_parent_folders("kubernetes.hcl")
  expose = true
}

terraform {
  source = "../../../../components/guestbook"
}

dependency "ingress" {
  config_path = "../ingress/"
}

dependency "eks" {
  config_path = "../eks/"
}

dependency "argocd-init" {
  config_path = "../argocd-init"
}

inputs = {
  stack                              = "guestbook"
  tld                                = include.root.locals.tld
  environment                        = include.root.locals.environment
  region                             = include.root.locals.region
  email                              = include.root.locals.email
  lb_url                             = dependency.ingress.outputs.lb_url
  cluster_name                       = dependency.eks.outputs.cluster_name
  cluster_certificate_authority_data = dependency.eks.outputs.cluster_certificate_authority_data
  cluster_endpoint                   = dependency.eks.outputs.cluster_endpoint
  argocd_password                    = dependency.argocd-init.outputs.argocd_admin_setup_password
}
