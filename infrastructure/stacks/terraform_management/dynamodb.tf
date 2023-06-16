module "terraform_lock_dynamodb" {
  source     = "../../modules/dynamodb"
  table_name = "${var.account_name}-terraform-state-lock"

  hash_key = "LockID"
  attributes = [{
    name = "LockID"
    type = "S"
  }]
}
