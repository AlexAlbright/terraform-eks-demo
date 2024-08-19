locals {
  inputs_from_tfvars = jsondecode(read_tfvars_file("terraform.tfvars"))
  account_id = "${get_aws_account_id()}"
}

remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket         = "terraform-state-bucket-${local.account_id}"
    key            = "${local.inputs_from_tfvars.environment}/terraform.tfstate"
    region         = local.inputs_from_tfvars.region
    encrypt        = true
    dynamodb_table = "${local.inputs_from_tfvars.environment}-${local.account_id}-terraform-state-lock"
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.63.0"
    }
  }
}
provider "aws" {
  region = "${local.inputs_from_tfvars.region}"
  default_tags {
    tags = {
      Environment = "${local.inputs_from_tfvars.environment}"
    }
  }
}
EOF
}
