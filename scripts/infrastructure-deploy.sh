#! /bin/bash
echo $1
PROFILE=$1
STACK=$2
# first bring in vars
source ./scripts/variables-default.sh
if [[ $PROFILE == 'dev' ]] ||  [[ $PROFILE == 'test' ]] ; then
  source ./scripts/variables-$1.sh
fi
# then functions cos some reference vars
source ./scripts/functions/file-functions.sh
source ./scripts/functions/terraform-functions.sh

starting_dir=$(pwd)
# the directory that holds the stack to terraform
STACK_DIR=$TERRAFORM_DIR/$STACK
# a temp directory to hold the edited tf files
TEMP_STACK_DIR=$TERRAFORM_DIR/temp
mkdir $TEMP_STACK_DIR
# copy files to temp directory
cp -R $STACK_DIR/. $TEMP_STACK_DIR
# replace placeholder values with actual values derived from variables
file-replace-variables-in-dir $TEMP_STACK_DIR

# switch to temp directory ahead of tf init/plan/apply
cd $TEMP_STACK_DIR || exit
# init terraform
terraform-initialise temp $ENVIRONMENT true
# plan
terraform-plan
# return to starting position
cd $starting_dir
# remove temp directory
rm -rf $TEMP_STACK_DIR
