# ==============================================================================
# Context

locals {

  terraform-git-repo = "uec-dos-account-mngt"
  account_alias      = data.aws_iam_account_alias.alias.account_alias

}
