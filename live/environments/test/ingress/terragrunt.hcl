include "root" {
  path = find_in_parent_folders()
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
  tld                                = "alexalbright.com"
  cluster_name                       = dependency.eks.outputs.cluster_name
  cluster_endpoint                   = dependency.eks.outputs.cluster_endpoint
  cluster_certificate_authority_data = dependency.eks.outputs.cluster_certificate_authority_data
  argocd_password                    = dependency.argocd-init.outputs.argocd_admin_setup_password
}
