# -----------------------------------------------------------
# 1. PROVIDER SETUP
# -----------------------------------------------------------
provider "aws" {
  region = var.aws_region
  
  assume_role {
    role_arn = "arn:aws:iam::${var.aws_account_number}:role/admin-assume-role"
  }
}

# -----------------------------------------------------------
# 2. REMOTE STATE
# -----------------------------------------------------------
terraform {
  backend "s3" {
    # Configuration comes from backend/*.conf
  }
}

# -----------------------------------------------------------
# 3. ENVIRONMENT STORAGE (The Data Lake)
# -----------------------------------------------------------
resource "aws_s3_bucket" "data_lake" {
  bucket = "${var.project_prefix}-abc-data-${var.environment}"
  
  tags = {
    Name        = "Data Lake Storage"
    Environment = var.environment
  }
}

# Block public access (Security Best Practice)
resource "aws_s3_bucket_public_access_block" "block_public" {
  bucket = aws_s3_bucket.data_lake.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}