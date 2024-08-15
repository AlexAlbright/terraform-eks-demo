locals {
  region = "us-east-1"
  account = "160398320853"
  environment = "test"
}

remote_state{
  backend = "s3"
  generate = {
    path = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket = "terraform-state-bucket-${local.account}"
    key = "${local.environment}/terraform.tfstate"
    region = local.region
    encrypt = true
    dynamodb_table = "${local.environment}-${local.account}-terraform-state-lock"
  }
}

generate "provider" {
  path = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
provider "aws" {
  region = "${local.region}"
  default_tags = {
    tags = {
      Environment = "${local.environment}"
    }
  }
}
EOF
}
