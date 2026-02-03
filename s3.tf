variable "sns-name" {}

resource "aws_sns_topic" "user_updates" {
  name = var.sns-name
}

resource "aws_s3_bucket" "my" {
  # bucket = "s3-bucket"
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}
