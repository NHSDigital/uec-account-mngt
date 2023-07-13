# ==============================================================================
# Context

locals {

  terraform-git-repo = "uec-account-mngt"
  account_alias      = data.aws_iam_account_alias.alias.account_alias
  account_id         = data.aws_caller_identity.current.id
}
