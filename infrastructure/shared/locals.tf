# ==============================================================================
# Context

locals {

<<<<<<< main:infrastructure/shared/locals.tf
  terraform-git-repo = "uec-account-mngt"
=======
  terraform-git-repo = "uec-account-mgmt"
>>>>>>> DR-175 Change gitrepo name:infrastructure/stacks/terraform_management/locals.tf
  account_alias      = data.aws_iam_account_alias.alias.account_alias

}
