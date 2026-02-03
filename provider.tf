provider "aws" {
  region  = "us-east-1"
  profile = "aws_user"

  default_tags {
    tags = local.aws_tags_global
  }
}
