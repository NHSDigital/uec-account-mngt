terraform {
  required_version = ">= 1.5.0, < 1.6.0"

  backend "s3" {
    #   bucket = "nhse-uec-dos-dev-terraform-state"
    #   key    = "nhse-uec-dos-dev/terraform_management/terraform.state"
    #   region = "eu-west-2"

    #   dynamodb_table = "nhse-uec-dos-dev-terraform-state-lock"
    #   encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.3.0, < 5.4.0"
    }
  }
}
