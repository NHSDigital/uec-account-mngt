// Creation of S3 bucket for the Athena Database
// https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/athena_database
module "s3_athena_bucket" {
  source      = "../../modules/s3"
  bucket_name = local.athena_bucket_name

  force_destroy = true
}

resource "aws_athena_database" "athena_database" {
  name   = local.athena_database_name
  bucket = module.s3_athena_bucket.s3_bucket_id
}

// Creation of Athena workgroup
// https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/athena_workgroup
resource "aws_athena_workgroup" "athena_workgroup" {
  name        = var.athena_workgroup_name
  state       = "ENABLED"
  description = "Workflow for querying CM dynamo tables"

  force_destroy = true

  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = true

    bytes_scanned_cutoff_per_query = var.bytes_scanned_cutoff_per_query_default_wrgp

    result_configuration {
      output_location = "s3://${module.s3_athena_bucket.s3_bucket_id}/output/"

      encryption_configuration {
        encryption_option = "SSE_S3"
      }
    }
  }
}

// Creation of Dynamo connector serverless application
// https://serverlessrepo.aws.amazon.com/applications/TBA/AthenaDynamoDBConnector
// https://github.com/awslabs/aws-athena-query-federation/tree/master/athena-dynamodb
resource "aws_serverlessapplicationrepository_cloudformation_stack" "dynamo-connector" {
  name             = var.athena_dynamo_connect_cf_stack_name
  application_id   = "${var.aws_serverless_applications_repo_url}${var.athena_dynamo_connector_app}"
  semantic_version = var.athena_dynamo_connect_semantic_version

  capabilities = [
    "CAPABILITY_IAM",
    "CAPABILITY_RESOURCE_POLICY",
  ]

  parameters = {
    AthenaCatalogName = var.athena_data_catalogue_lambda_name
    SpillBucket       = local.athena_bucket_name
  }
}

// Creation of data catalogue (data source) - Needs to be of Type Lambda for Federated data sources
resource "aws_athena_data_catalog" "athena_data_catalogue" {
  name        = var.athena_data_catalogue_name
  description = "Athena CM data catalog"
  type        = "LAMBDA"

  parameters = {
    "function" = "arn:aws:lambda:${var.aws_region}:${local.account_id}:function:${var.athena_data_catalogue_lambda_name}"
  }

}
