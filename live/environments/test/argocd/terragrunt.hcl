include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../../components/argocd/"
}

dependency "ingress" {
  config_path = "../ingress/"
}

dependency "eks" {
  config_path = "../eks/"
}

inputs = {
  stack                              = "argocd"
  tld                                = "alexalbright.com"
  lb_url                             = dependency.ingress.outputs.lb_url
  cluster_name                       = dependency.eks.outputs.cluster_name
  cluster_certificate_authority_data = dependency.eks.outputs.cluster_certificate_authority_data
  cluster_endpoint                   = dependency.eks.outputs.cluster_endpoint
}
