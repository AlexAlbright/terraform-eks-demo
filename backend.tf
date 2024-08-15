resource "aws_kms_key" "terraform-bucket-key" {
  description             = "Encrypts terraform S3 state bucket"
  deletion_window_in_days = 10
  enable_key_rotation     = true
}

resource "aws_kms_alias" "key-alias" {
  name          = "alias/terraform-bucket-key"
  target_key_id = aws_kms_key.terraform-bucket-key.key_id
}

resource "aws_s3_bucket" "terraform-state" {
  bucket = "terraform-state-bucket-${local.account_id}"
}

resource "aws_dynamodb_table" "terraform-state-table" {
  name = "terraform-state-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "TestTableHashKey"

  attribute {
    name = "TestTableHashKey"
    type = "S"
  }
}

terraform {
  backend "s3" {
    bucket = "terraform-state-bucket-160398320853"
    key    = "test/terraform.tfstate"
    region = "us-east-1"
    dynamodb_table = "terraform-state-table"
  }
}
