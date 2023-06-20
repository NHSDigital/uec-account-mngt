module "terraform_lock_dynamodb" {
  source     = "../../modules/dynamodb"
  table_name = "${local.account_alias}-terraform-state-lock"

  hash_key = "LockID"
  attributes = [{
    name = "LockID"
    type = "S"
  }]
}
