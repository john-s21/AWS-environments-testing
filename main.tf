# -----------------------------------------------------------
# 1. PROVIDER SETUP
# -----------------------------------------------------------
provider "aws" {
  region = var.aws_region
  
  # This tells Terraform to assume the Admin Role automatically
  assume_role {
    role_arn = "arn:aws:iam::${var.aws_account_number}:role/admin-assume-role"
  }
}

# -----------------------------------------------------------
# 2. REMOTE STATE (The "Memory" Hook)
# -----------------------------------------------------------
terraform {
  backend "s3" {
    # The details here are empty because they come from backend/*.conf
  }
}

# -----------------------------------------------------------
# 3. DATA LAKE STORAGE (S3)
# -----------------------------------------------------------
resource "aws_s3_bucket" "data_lake" {
  bucket = "${var.project_prefix}-abc-data-${var.environment}" # e.g., eyproject-abc-data-dev
  
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

# -----------------------------------------------------------
# 4. IAM SECURITY (Calling your Factory)
# -----------------------------------------------------------

# First, we read the policy template and fill in the bucket name
data "template_file" "s3_access_policy" {
  template = file("${path.module}/templates/s3-access.json.tmpl")
  vars = {
    bucket_name = aws_s3_bucket.data_lake.id
  }
}

# Create the Policy in AWS
resource "aws_iam_policy" "redshift_s3_access" {
  name        = "${var.project_prefix}-${var.environment}-redshift-s3-policy"
  description = "Access to the data lake bucket"
  policy      = data.template_file.s3_access_policy.rendered
}

# Call the Module to create the Role
module "redshift_role" {
  source = "./modules/iam_role"

  project_prefix     = var.project_prefix
  environment        = var.environment
  role_name          = "redshift-role"
  
  # Who can use this role? (Redshift & Glue)
  assume_role_policy = file("${path.module}/templates/redshift-trust.json")
  
  # Attach our custom S3 policy
  custom_policy_arns = [aws_iam_policy.redshift_s3_access.arn]
  
  # Attach standard AWS power for Glue
  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"]
}

# -----------------------------------------------------------
# 5. DATA CATALOG (AWS Glue)
# -----------------------------------------------------------
resource "aws_glue_catalog_database" "datalake_db" {
  name = "${var.project_prefix}_analysis_${var.environment}"
}

resource "aws_glue_crawler" "abc_crawler" {
  database_name = aws_glue_catalog_database.datalake_db.name
  name          = "${var.project_prefix}-${var.environment}-crawler"
  role          = module.redshift_role.role_arn # Use the role we just made!

  s3_target {
    path = "s3://${aws_s3_bucket.data_lake.bucket}/data/"
  }
  
  tags = {
    Environment = var.environment
  }
}