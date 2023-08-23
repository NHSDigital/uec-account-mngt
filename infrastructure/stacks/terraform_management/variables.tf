variable "account_alias" {
  description = "Alias for AWS account - usually equal to account name"
}
variable "terraform_lock_table_name" {
  description = "Name of dynamodb table that holds terraformn state locks"
}
variable "terraform_state_bucket_name" {
  description = "Name of s3 bucket that holds terraform state"
}
