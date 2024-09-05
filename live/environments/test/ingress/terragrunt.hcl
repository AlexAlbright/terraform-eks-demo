include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../../components/ingress"
}


dependency "eks" {
  config_path = "../eks/"
}

inputs = {
  stack                              = "ingress"
  cluster_name                       = dependency.eks.outputs.cluster_name
  cluster_endpoint                   = dependency.eks.outputs.cluster_endpoint
  cluster_certificate_authority_data = dependency.eks.outputs.cluster_certificate_authority_data
}
