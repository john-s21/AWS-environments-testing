sns-name = "test-sns-topic-terraform"

secret_names = {
  "project/p1"  = "Description1"
  "project/p2" = "Description2"
}

// ---------------------------------------------------------------------------
// Account & Env Variables
environment                = "dev"
aws_account_number         = "338714738346"
aws_tags_user = {
  Environment : "Development"
}

// ---------------------------------------------------------------------------
// Glue Catalog Variables
glue_db_list = ["eyproject_analysis_dev"]

// ---------------------------------------------------------------------------
// Glue Crawler Variables
data_catalog_crawler = "eyproject_analysis_dev"
data_source_paths_sharepoint = [
  "sharepoint/",
  "sqi_tracking/SQI_TRACKING_MASTER/"
]

abc_crawlernames = {
  "eyproject-crawler1" = "curated/folder1/"
  "eyproject-crawler2" = "curated/folder2/"
  "eyproject-crawler3" = "curated/folder3/"
  "eyproject-crawler4" = "curated/folder4/"
  "eyproject-crawler5" = "curated/folder5/"
  "eyproject-crawler6" = "curated/folder6/"
  "eyproject-crawler7" = "curated/folder7/"
  "eyproject-crawler8" = "curated/folder8/"
  "eyproject-crawler9" = "curated/folder9/"
}
