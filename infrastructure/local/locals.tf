# ==============================================================================
# Context

locals {
  terraform-git-repo = "uec-account-mngt"
  account_id         = data.aws_caller_identity.current.id
}
