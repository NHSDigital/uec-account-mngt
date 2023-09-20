athena_bucket_name   = "athena-database"
athena_database_name = "athena-database"

athena_workgroup_name = "athena-wgrp-support"
# Cut off query at 100MB scanned for the default workgroup
bytes_scanned_cutoff_per_query_default_wrgp = 104857600

athena_data_catalogue_name        = "dynamo-data-catalog"
athena_data_catalogue_lambda_name = "athena-dynamo-connect"

athena_dynamo_connect_cf_stack_name    = "athena-dynamo-connect-cf-stack"
athena_dynamo_connector_app            = "AthenaDynamoDBConnector"
athena_dynamo_connect_semantic_version = "2023.35.2"
