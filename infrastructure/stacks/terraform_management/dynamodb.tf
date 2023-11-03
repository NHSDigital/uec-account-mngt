module "terraform_lock_dynamodb" {
  source                      = "../../modules/dynamodb"
  table_name                  = var.terraform_lock_table_name
  deletion_protection_enabled = true
  hash_key                    = "LockID"
  attributes = [{
    name = "LockID"
    type = "S"
  }]
}
