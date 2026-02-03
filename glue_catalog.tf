variable "glue_db_list" {
  type        = list(any)
  description = "The list of glue databases (by name) that are to be created"
}

resource "aws_glue_catalog_database" "aws_glue_catalog_database" {
  for_each = toset(var.glue_db_list)
  name     = each.key
}
