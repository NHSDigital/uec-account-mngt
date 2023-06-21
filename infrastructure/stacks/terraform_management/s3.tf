module "terraform_state_bucket" {
  source      = "../../modules/s3"
  bucket_name = "${local.account_alias}-terraform-state"
}
