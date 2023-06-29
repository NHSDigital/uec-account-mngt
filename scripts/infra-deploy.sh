#! /bin/bash
# eg arguments/parameters plan iam-policy dev

ACTION=$1
STACK=$2
ENVIRONMENT=$3

# functions
source ./scripts/functions/terraform-functions.sh

COMMON_TF_VARS_FILE="common.tfvars"
ENV_TF_VARS_FILE="$ENVIRONMENT.tfvars"
echo "Preparing to run terraform $ACTION for stack $STACK for environment $ENVIRONMENT"
ROOT_DIR=$PWD

# the directory that holds the stack to terraform
STACK_DIR=$PWD/$INFRASTRUCTURE_DIR/stacks/$STACK

# switch to target stack directory ahead of tf init/plan/apply
cd "$STACK_DIR" || exit
# init terraform
terraform-initialise $STACK $ENVIRONMENT true
# plan
if [ -n "$ACTION" ] && [ "$ACTION" = 'plan' ] ; then
  terraform plan \
  -var-file $ROOT_DIR/$INFRASTRUCTURE_DIR/$COMMON_TF_VARS_FILE \
  -var-file $ROOT_DIR/$INFRASTRUCTURE_DIR/$ENV_TF_VARS_FILE
fi

if [ -n "$ACTION" ] && [ "$ACTION" = 'apply' ] ; then
  terraform apply -auto-approve \
    -var-file $ROOT_DIR/$INFRASTRUCTURE_DIR/$COMMON_TF_VARS_FILE \
    -var-file $ROOT_DIR/$INFRASTRUCTURE_DIR/$ENV_TF_VARS_FILE
fi

if [ -n "$ACTION" ] && [ "$ACTION" = 'destroy' ] ; then
  terraform destroy -auto-approve\
    -var-file $ROOT_DIR/$INFRASTRUCTURE_DIR/$COMMON_TF_VARS_FILE \
    -var-file $ROOT_DIR/$INFRASTRUCTURE_DIR/$ENV_TF_VARS_FILE
fi
