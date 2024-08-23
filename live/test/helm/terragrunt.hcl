include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../stacks/helm"
}

dependency "eks" {
  config_path = "../eks/"
}

inputs = {
  stack                              = "helm"
  cluster_name                       = dependency.eks.outputs.cluster_name
  cluster_endpoint                   = dependency.eks.outputs.cluster_endpoint
  cluster_certificate_authority_data = dependency.eks.outputs.cluster_certificate_authority_data
  cluster_identity_oidc_issuer       = dependency.eks.outputs.cluster_identity_oidc_issuer
  cluster_identity_oidc_issuer_arn   = dependency.eks.outputs.cluster_identity_oidc_issuer_arn
}

