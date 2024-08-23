include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../stacks/cluster-config/"
}

dependency "eks" {
  config_path = "../eks/"
}

inputs = {
  cluster_name                       = dependency.eks.outputs.cluster_name
  cluster_endpoint                   = dependency.eks.outputs.cluster_endpoint
  cluster_certificate_authority_data = dependency.eks.outputs.cluster_certificate_authority_data
}
