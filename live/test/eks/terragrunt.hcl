include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../stacks/eks"
}

dependency "vpc" {
  config_path = "../vpc"
}

inputs = {
  name  = "test"
  stack = "eks"

  eks_public_access = true

  node_groups = {
    default = {
      instance_types = "t3.micro"
      desired_size   = 3
      max_size       = 3
    }
  }

  eks_users = [
    "admin-dev"
  ]

  private_subnets = dependency.vpc.outputs.private_subnets
  public_subnets  = dependency.vpc.outputs.public_subnets

  vpc_id = dependency.vpc.outputs.vpc_id

}
