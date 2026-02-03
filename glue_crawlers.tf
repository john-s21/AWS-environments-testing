variable "data_source_paths_sharepoint" {
  description = "(Optional) List nested Amazon S3 target arguments."
}
variable "data_catalog_crawler" {
  description = "Glue Database to which Crawler points"
}
variable "abc_crawlernames" {
  description = "ABC crawlers"
}

resource "aws_glue_crawler" "abc-crawlers" {
  database_name = var.data_catalog_crawler
  for_each      = tomap(var.abc_crawlernames)
  description   = "To register the glue tables in Redshift for ABC Application"
  name          = each.key
  role          = "arn:aws:iam::${var.aws_account_number}:role/${var.project_prefix}-${var.environment}-glue-role"
  s3_target {
    path = "s3://eyproject-abc-data-${var.environment}/${each.value}"
  }
}


resource "aws_glue_crawler" "SHAREPOINT_DATA_CRAWLER" {
  database_name = var.data_catalog_crawler
  description   = "To register the glue tables in Redshift for Sharepoint"
  name          = "SHAREPOINT_DATA_CRAWLER"
  role          = "arn:aws:iam::${var.aws_account_number}:role/${var.project_prefix}-${var.environment}-glue-role"
  dynamic "s3_target" {
    for_each = var.data_source_paths_sharepoint
    content {
      path = "s3://eyproject-abc-data-${var.environment}/curated/${s3_target.value}"
    }
  }
}
