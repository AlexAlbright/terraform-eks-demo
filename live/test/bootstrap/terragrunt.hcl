inputs = {
  account_id = "${get_aws_account_id()}"
}

terraform {
  source = "../../../stacks/bootstrap"
}

