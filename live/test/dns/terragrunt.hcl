include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../stacks/eks"
}

dependency "eks" {
  config_path = "../eks"
}

inputs = {
  tld = "alexalbright.com" # change to the tld of the hosted zone you will be using for this demo
}
