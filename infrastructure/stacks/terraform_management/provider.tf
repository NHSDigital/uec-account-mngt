variable "aws_region" {
  type    = string
  default = "eu-west-2"
}

data "aws_caller_identity" "current" {}
data "aws_iam_account_alias" "alias" {}

provider "aws" {
  region = var.aws_region

  skip_metadata_api_check     = true
  skip_region_validation      = true
  skip_credentials_validation = true

  skip_requesting_account_id = false

  default_tags {
    tags = {
      owner               = "PROGRAM_TO_REPLACE"
      project             = "PROGRAM_CODE_TO_REPLACE"
      environment         = "ENVIRONMENT_TO_REPLACE"
      terraform-base-path = replace(path.cwd, "/^.*?(${local.terraform-git-repo}\\/)/", "$1")
    }
  }
}

