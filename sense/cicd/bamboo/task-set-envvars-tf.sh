#!/bin/bash
# Create ${bamboo.build.working.directory}/envvars file
# containing key ENV vars for all steps to read.
# AWS_SESSION_TOKEN duration set to 3600 seconds.

aws configure set default.region ap-southeast-1
aws configure set default.output json
rm -f $HOME/.docker/config.json

# From Plan variable
DEV_AWS_ACC="${bamboo_DEV_AWS_ACC}" # "${bamboo.DEV_AWS_ACC}"
PRD_AWS_ACC="${bamboo_PRD_AWS_ACC}" # "${bamboo.PRD_AWS_ACC}"

ENV="${bamboo_ENV}"
ROLE=""

echo "Setting ENV variable from branch convention"
if [[ $BRANCH_NAME == 'release-intra' ]];then
  ENV=intra
elif [[ $BRANCH_NAME == 'release-prod' ]];then
  ENV=prod
elif [[ $BRANCH_NAME == 'release-qa' ]];then
  ENV=qa
elif [[ "${BRANCH_NAME}" == 'develop' ]]; then
  if [[ -z "${ENV}" ]]; then
    ENV=dev
  else
    echo "Probably running with custom ENV variable"
  fi
else
  echo "Probably running with custom branch"
fi

TEMP_FOLDER=$1
if [[ -z "${TEMP_FOLDER}" ]]; then
  TEMP_FOLDER=/home/bamboo/tmp
fi
mkdir -p $TEMP_FOLDER

echo "Formatting ROLE_ARN"
ROLE_ARN="${bamboo_ROLE_ARN}"
if [[ -z "${ROLE_ARN}" ]]; then
  if [[ "${ENV}" == "prod" ]]; then
      THIS_AWS_ACC=$PRD_AWS_ACC
      ROLE=u-ship
  elif [[ "${ENV}" == "intra" ]]; then
      THIS_AWS_ACC=$PRD_AWS_ACC
      ROLE=u-ship
  else
      THIS_AWS_ACC=$DEV_AWS_ACC
      ROLE=forBamboo
  fi
  ROLE_ARN="arn:aws:iam::${THIS_AWS_ACC}:role/${ROLE}"
fi

temp_role=$(aws sts assume-role \
    --duration-seconds 3600 \
    --role-arn "${ROLE_ARN}" \
    --role-session-name "eks_deploy")

cat <<EOF > ${TEMP_FOLDER}/envvars
export AWS_ACC=$THIS_AWS_ACC
export AWS_DEFAULT_REGION=ap-southeast-1
export AWS_ACCESS_KEY_ID=$(echo $temp_role | jq .Credentials.AccessKeyId | xargs)
export AWS_SECRET_ACCESS_KEY=$(echo $temp_role | jq .Credentials.SecretAccessKey | xargs)
export AWS_SESSION_TOKEN=$(echo $temp_role | jq .Credentials.SessionToken | xargs)
export ROLE_ARN=$ROLE_ARN

export CLUSTER_NAME=${CLUSTER_NAME}
export ENV=$ENV

export HELM_BINARY=/tmp/helm
EOF

