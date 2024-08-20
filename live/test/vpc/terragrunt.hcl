include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../stacks/vpc"
}

inputs = {
  stack = "vpc"

  account_id = "${get_aws_account_id()}"

  cidr_block      = "172.31.0.0/16"
  private_subnets = ["172.31.0.0/20", "172.31.16.0/20", "172.31.32.0/20"]
  public_subnets  = ["172.31.48.0/20", "172.31.64.0/20", "172.31.80.0/20"]

}
