#! /bin/bash

### Initialise infrastructure state - mandatory:
# STACK=[name]; optional: TERRAFORM_USE_STATE_STORE=false,PROFILE=[name]
# TERRAFORM_STATE_KEY=$PROGRAM_CODE/$ENVIRONMENT
TERRAFORM_STATE_STORE=$PROGRAM_CODE-$ENVIRONMENT-terraform-state
TERRAFORM_STATE_LOCK=$PROGRAM_CODE-$ENVIRONMENT-terraform-state-lock
TERRAFORM_STATE_KEY=$PROGRAM_CODE-$ENVIRONMENT/$STACK/terraform.state
AWS_REGION=eu-west-2
TERRAFORM_DIR=./infrastructure/stacks

function terraform-initialise {
    TERRAFORM_USE_STATE_STORE=$3
    ENVIRONMENT=$2
    STACK=$1
    if [[ "$TERRAFORM_USE_STATE_STORE" =~ ^(false|no|n|off|0|FALSE|NO|N|OFF) ]]; then
      terraform init
    else
      # echo $TERRAFORM_USE_STATE_STORE true
      terraform init \
          -backend-config="bucket=$TERRAFORM_STATE_STORE" \
          -backend-config="dynamodb_table=$TERRAFORM_STATE_LOCK" \
          -backend-config="encrypt=true" \
          -backend-config="key=$TERRAFORM_STATE_KEY" \
          -backend-config="region=$AWS_REGION"
    fi
}

function terraform-plan {
    terraform plan
}
