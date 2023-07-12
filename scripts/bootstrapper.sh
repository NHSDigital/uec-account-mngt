#! /bin/bash

# functions
source ./scripts/functions/terraform-functions.sh

# This bootstrapper script initialises various resources necessary for Terraform and Github Actions to build
# the DoS or CM application in an aws account

# Before running this bootstrapper script:
#  - Login to an appropriate AWS account as appropriate user via commamnd-line AWS-cli
#  - Export the following variables appropriate for your account and github setup prior to calling this script
#  - They are NOT set in this script to avoid details being stored in repo
export ACTION="${ACTION:-"plan"}"                 # default action is plan
export REPO_NAME="${REPO_NAME:-""}"               # The repository name where your code is stored eg NHSDigital/uec-account-mngt
export AWS_REGION="${AWS_REGION:-""}"                             # The AWS region into which you intend to deploy the application (where the terraform bucket will be created) eg eu-west-2
export ACCOUNT_PROJECT="${ACCOUNT_PROJECT:-""}"                        # Identify the application to be hosted in the account eg dos or cm - used to built terraform bucket name
export ACCOUNT_TYPE="${ACCOUNT_TYPE:-""}"                    # Identify the purpose of the account/environment (one of dev,test,security,preprod or prod) usually part of the account name

# check exports have been done
EXPORTS_SET=0
# Check key variables have been exported - see above
if [[ ! "$ACTION" =~ ^(plan|apply|destroy) ]]; then
    echo ACTION must be one of following terraform actions - plan, apply or destroy
    EXPORTS_SET=1
fi

if [ -z "$REPO_NAME" ] ; then
  echo Set REPO_NAME to name of the repo where the code to be accessed by github runner is stored
  EXPORTS_SET=1
fi

if [ -z "$AWS_REGION" ] ; then
  echo Set AWS_REGION to name of the AWS region to host the terraform state bucket
  EXPORTS_SET=1
fi

if [ -z "$ACCOUNT_PROJECT" ] ; then
  echo Set ACCOUNT_PROJECT to identify if account is for dos or cm
  EXPORTS_SET=1
else
  if [[ ! "$ACCOUNT_PROJECT" =~ ^(dos|cm) ]]; then
      echo ACCOUNT_PROJECT should be dos or cm
      EXPORTS_SET=1
  fi
fi

if [ -z "$ACCOUNT_TYPE" ] ; then
  echo Set ACCOUNT_TYPE to identify if account is for dev, test, security, preprod or prod
  EXPORTS_SET=1
else
  if [[ ! $ACCOUNT_TYPE =~ ^(dev|test|preprod|prod|security) ]]; then
      echo ACCOUNT_TYPE should be dev test preprod security or prod
      EXPORTS_SET=1
  fi
fi

if [ $EXPORTS_SET = 1 ] ; then
    echo One or more required exports not correctly set
    exit 1
fi

# derive and set the name of the bucket and the alias
export TERRAFORM_BUCKET_NAME="nhse-uec-$ACCOUNT_PROJECT-$ACCOUNT_TYPE-terraform-state"    # A globally unique name for your terraform remote state bucket
export TF_VAR_account_alias="nhse-uec-$ACCOUNT_PROJECT-$ACCOUNT_TYPE"

# create all but alias via terraform
# ------------- Step one tf state bucket, state locks and account alias -----------
# needs to be false as there is no remote backend
export ACTION=$ACTION
export ENVIRONMENT="$ACCOUNT_TYPE"
export PROJECT="$ACCOUNT_PROJECT"
export STACK=terraform_management

# if remote state bucket exists use it
if aws s3api head-bucket --bucket "$TERRAFORM_BUCKET_NAME" 2>/dev/null; then
  export USE_REMOTE_STATE_STORE=true
else
  export USE_REMOTE_STATE_STORE=false
fi

# deploy stack
/bin/bash ./scripts/infra-deploy.sh

# having build the stack using a local backend we need to push
# the state to the remote
if ! $USE_REMOTE_STATE_STORE  ; then
  # check if remote state bucket exists we are okay to migrate state to it
  if aws s3api head-bucket --bucket "$TERRAFORM_BUCKET_NAME" 2>/dev/null; then
    export USE_REMOTE_STATE_STORE=true
    echo Preparing to migrate stack from local backend to remote backend
    # the directory that holds the stack to terraform
    ROOT_DIR=$PWD
    STACK_DIR=$PWD/$INFRASTRUCTURE_DIR/stacks/$STACK
    cd "$STACK_DIR" || exit
    cp "$ROOT_DIR"/"$INFRASTRUCTURE_DIR"/remote/versions.tf "$STACK_DIR"
    cp "$ROOT_DIR"/"$INFRASTRUCTURE_DIR"/remote/locals.tf "$STACK_DIR"
    cp "$ROOT_DIR"/"$INFRASTRUCTURE_DIR"/remote/provider.tf "$STACK_DIR"
    # run terraform init with migrate flag set
    terraform-init-migrate "$STACK" "$ENVIRONMENT" "$USE_REMOTE_STATE_STORE"
    # now push local state to remote
    terraform state push "$STACK_DIR"/.terraform/terraform.tfstate
    rm -f "$STACK_DIR"/locals.tf
    rm -f "$STACK_DIR"/provider.tf
    rm -f "$STACK_DIR"/versions.tf
    cd "$ROOT_DIR" || exit
  else
    export USE_REMOTE_STATE_STORE=false
  fi
fi

# TODO restore
# # ------------- Step three create  thumbprint for github actions -----------
# export HOST=$(curl https://token.actions.githubusercontent.com/.well-known/openid-configuration)
# export CERT_URL=$(jq -r '.jwks_uri | split("/")[2]' <<< $HOST)
# export THUMBPRINT=$(echo | openssl s_client -servername "$CERT_URL" -showcerts -connect "$CERT_URL":443 2> /dev/null | tac | sed -n '/-----END CERTIFICATE-----/,/-----BEGIN CERTIFICATE-----/p; /-----BEGIN CERTIFICATE-----/q' | tac | openssl x509 -sha1 -fingerprint -noout | sed 's/://g' | awk -F= '{print tolower($2)}')
# # ------------- Step four create oidc identity provider, github runner role and policies for that role -----------
# export TF_VAR_repo_name=$REPO_NAME
# export TF_VAR_oidc_provider_url="https://token.actions.githubusercontent.com"
# export TF_VAR_oidc_thumbprint=$THUMBPRINT
# export TF_VAR_oidc_client="sts.amazonaws.com"
# export STACK=github-runner
# /bin/bash ./scripts/infra-deploy.sh


