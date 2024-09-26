include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../../components/eks"
}

dependency "eks" {
  config_path = "../eks"
}

inputs = {
  tld        = "alexalbright.com" # change to the tld of the hosted zone you will be using for this demo
  subdomains = ["argocd"]         # list of domains
}
