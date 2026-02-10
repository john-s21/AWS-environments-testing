provider "aws" {
  region = var.aws_region
  
  assume_role {
    role_arn = "arn:aws:iam::${var.aws_account_number}:role/admin-assume-role"
  }
}

terraform {
  backend "s3" {}
}

resource "aws_s3_bucket" "data_lake" {
  bucket = "${var.project_prefix}-data-${var.environment}"
  
  tags = {
    Name        = "Data Lake Storage"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_public_access_block" "block_public" {
  bucket = aws_s3_bucket.data_lake.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}