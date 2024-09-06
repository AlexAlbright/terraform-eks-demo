include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../../components/argocd-init/"
}

dependency "eks" {
  config_path = "../eks/"
}

inputs = {
  stack                              = "argocd-init"
  release_version                    = "4.5.7" # Choose the version of the argocd helm chart you wish to use https://argoproj.github.io/argo-helm/ 
  cluster_name                       = dependency.eks.outputs.cluster_name
  cluster_endpoint                   = dependency.eks.outputs.cluster_endpoint
  cluster_certificate_authority_data = dependency.eks.outputs.cluster_certificate_authority_data
}

