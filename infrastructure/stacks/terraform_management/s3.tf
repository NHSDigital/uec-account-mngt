module "terraform_state_bucket" {
  source      = "../../modules/s3"
  bucket_name = "${var.account_name}-terraform-state"
}
