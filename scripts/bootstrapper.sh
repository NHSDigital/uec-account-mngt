#! /bin/bash
# This bootstrapper script initialises various resources necessary for Terraform and Github Actions to build
# the DoS or CM application in an aws account

# Before running this bootstrapper script:
#  - Login to an appropriate AWS account as appropriate user via commamnd-line AWS-cli
#  - Export the following variables appropriate for your account and github setup prior to calling this script
#  - They are NOT set in this script to avoid details being stored in repo

export REPO_NAME="${REPO_NAME:-""}"               # The repository name where your code is stored eg NHSDigital/uec-account-mngt
export AWS_ACCOUNT_ID="${AWS_ACCOUNT_ID:-""}"            # The account number of the AWS account into which you intend to deploy
export AWS_REGION="${AWS_REGION:-""}"                             # The AWS region into which you intend to deploy the application (where the terraform bucket will be created) eg eu-west-2
export ACCOUNT_PROJECT="${ACCOUNT_PROJECT:-""}"                        # Identify the application to be hosted in the account eg dos or cm - used to built terraform bucket name
export ACCOUNT_TYPE="${ACCOUNT_TYPE:-""}"                    # Identify the purpose of the account/environment (one of dev,test,security,preprod or prod) usually part of the account name

# check exports have been done
EXPORTS_SET=0
# Check key variables have been exported - see above
if [ -z "$REPO_NAME" ] ; then
  echo Set REPO_NAME to name of the repo where the code to be accessed by github runner is stored
  EXPORTS_SET=1
fi

if [ -z "$AWS_ACCOUNT_ID" ] ; then
  echo Set AWS_ACCOUNT_ID to number of the AWS account to be updated
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
# TODO change plan to apply
/bin/bash ./scripts/infra-deploy.sh plan terraform_management "$ACCOUNT_TYPE" false

# ------------- Step three create  thumbprint for github actions -----------
export HOST=$(curl https://token.actions.githubusercontent.com/.well-known/openid-configuration)
export CERT_URL=$(jq -r '.jwks_uri | split("/")[2]' <<< $HOST)
export THUMBPRINT=$(echo | openssl s_client -servername "$CERT_URL" -showcerts -connect "$CERT_URL":443 2> /dev/null | tac | sed -n '/-----END CERTIFICATE-----/,/-----BEGIN CERTIFICATE-----/p; /-----BEGIN CERTIFICATE-----/q' | tac | openssl x509 -sha1 -fingerprint -noout | sed 's/://g' | awk -F= '{print tolower($2)}')

# ------------- Step four create oidc identity provider, github runner role and policies for that role -----------
export TF_VAR_repo_name=$REPO_NAME
export TF_VAR_oidc_provider_url="https://token.actions.githubusercontent.com"
export TF_VAR_oidc_thumbprint=$THUMBPRINT
export TF_VAR_oidc_client="sts.amazonaws.com"
# TODO change plan to apply
/bin/bash ./scripts/infra-deploy.sh plan github-runner "$ACCOUNT_TYPE"


#  via cli

# ------------- Step one tf state bucket and state locks -----------
# uncomment to do it via cli
# aws s3api create-bucket --acl private --bucket $TERRAFORM_BUCKET_NAME --region $AWS_REGION --create-bucket-configuration LocationConstraint=$AWS_REGION
# aws s3api put-public-access-block --bucket $TERRAFORM_BUCKET_NAME  --public-access-block-configuration '{"BlockPublicAcls": true, "IgnorePublicAcls": true, "BlockPublicPolicy": true, "RestrictPublicBuckets": true}'

# ------------- Step two create an account alias -----------
# uncomment to do it via cli
# aws iam create-account-alias --account-alias $ACCOUNT_ALIAS

# ------------- Step three create oidc identity provider thumbprint for github actions -----------
# uncomment to create thumbprint
# export HOST=$(curl https://token.actions.githubusercontent.com/.well-known/openid-configuration)
# export CERT_URL=$(jq -r '.jwks_uri | split("/")[2]' <<< $HOST)
# export THUMBPRINT=$(echo | openssl s_client -servername $CERT_URL -showcerts -connect $CERT_URL:443 2> /dev/null | tac | sed -n '/-----END CERTIFICATE-----/,/-----BEGIN CERTIFICATE-----/p; /-----BEGIN CERTIFICATE-----/q' | tac | openssl x509 -sha1 -fingerprint -noout | sed 's/://g' | awk -F= '{print tolower($2)}')


# ------------- Step four create github runner role and policies for that role -----------
# uncomment to create oidc provider
# aws iam create-open-id-connect-provider --url "https://token.actions.githubusercontent.com" --client-id-list "sts.amazonaws.com" --thumbprint-list ["$THUMBPRINT"]
# uncomment to create role via cli
# aws iam create-role --role-name github --assume-role-policy-document "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Principal\":{\"Federated\":\"arn:aws:iam::$AWS_ACCOUNT:oidc-provider/token.actions.githubusercontent.com\"},\"Action\":\"sts:AssumeRoleWithWebIdentity\",\"Condition\":{\"ForAllValues:StringLike\":{\"token.actions.githubusercontent.com:sub\":\"repo:$REPO_NAME:*\",\"token.actions.githubusercontent.com:aud\":\"sts.amazonaws.com\"}}}]}"
# aws iam put-role-policy --role-name github --policy-name AdministratorAccess --policy-document "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Action\":\"*\",\"Resource\":\"*\"}]}"


