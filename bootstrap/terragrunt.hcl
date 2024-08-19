locals {
  inputs_from_tfvars = jsondecode(read_tfvars_file("../terraform.tfvars"))
}

inputs = merge(
  local.inputs_from_tfvars,
  {
    account_id = "${get_aws_account_id()}"
  }
)
