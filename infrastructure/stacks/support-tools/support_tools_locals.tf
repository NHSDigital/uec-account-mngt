locals {
  athena_bucket_name   = "${var.project}-${var.environment}-${var.athena_bucket_name}"
  athena_database_name = replace("${var.athena_database_name}", "-", "_")
}
