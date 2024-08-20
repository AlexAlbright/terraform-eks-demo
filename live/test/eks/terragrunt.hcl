include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../stacks/eks"
}

inputs = {
  name = "test"
  stack = "eks"

  eks_public_access = true
  
  node_groups = {
    default = {
      instance_size = "t3.micro"
      desired_size  = 3
      max_size      = 3
    }
  }

  eks_users = [
    "admin-dev"
  ]

}
