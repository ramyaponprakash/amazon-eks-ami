#!/bin/bash

DEV_AWS_ACC="${bamboo_DEV_AWS_ACC}" # "${bamboo.DEV_AWS_ACC}"
PRD_AWS_ACC="${bamboo_PRD_AWS_ACC}" # "${bamboo.PRD_AWS_ACC}"

BUILD_ENV="${bamboo_BUILD_ENV}" # "${bamboo.BUILD_ENV}"
ADD_BRANCH_NAME="${ADD_BRANCH_NAME}" # "${bamboo.ADD_BRANCH_NAME}"
if [[ -z "${ADD_BRANCH_NAME}" ]]; then
  ADD_BRANCH_NAME="${bamboo_ADD_BRANCH_NAME}"
fi
CLUSTER_NAME="${CLUSTER_NAME}"
if [[ -z "${CLUSTER_NAME}" ]]; then
  CLUSTER_NAME="${bamboo_CLUSTER_NAME}"
fi
BUILD_NUMBER="${bamboo_buildNumber}" # ${bamboo.buildNumber}
BUILD_RESULT_KEY="${bamboo_buildResultKey}" # ${bamboo.buildResultKey}
BUILD_DEPLOY_VERSION="${bamboo_deploy_version}"

ROLE=""
if [[ "${BUILD_ENV}" == "prod" ]]; then
    THIS_AWS_ACC=$PRD_AWS_ACC
    ROLE=u-ship
elif [[ "${BUILD_ENV}" == "intra" ]]; then
    ENV=intra
    THIS_AWS_ACC=$PRD_AWS_ACC
    ROLE=u-ship
elif [[ "${BUILD_ENV}" == "qa" ]]; then
    THIS_AWS_ACC=$DEV_AWS_ACC
    ROLE=forBamboo
else
    THIS_AWS_ACC=$DEV_AWS_ACC
    ROLE=forBamboo
fi

ROLE_ARN="arn:aws:iam::${THIS_AWS_ACC}:role/${ROLE}"
temp_role=$(aws sts assume-role \
    --duration-seconds 3600 \
    --role-arn "${ROLE_ARN}" \
    --role-session-name "eks_deploy")

TEMP_FOLDER=$1
if [[ -z "${TEMP_FOLDER}" ]]; then
  TEMP_FOLDER=/home/bamboo/tmp
fi
mkdir -p $TEMP_FOLDER

cat <<EOF > ${TEMP_FOLDER}/envvars
export AWS_ACC=$THIS_AWS_ACC
export AWS_DEFAULT_REGION=ap-southeast-1
export AWS_ACCESS_KEY_ID=$(echo $temp_role | jq .Credentials.AccessKeyId | xargs)
export AWS_SECRET_ACCESS_KEY=$(echo $temp_role | jq .Credentials.SecretAccessKey | xargs)
export AWS_SESSION_TOKEN=$(echo $temp_role | jq .Credentials.SessionToken | xargs)
export ROLE_ARN=$ROLE_ARN

export CLUSTER_NAME=${CLUSTER_NAME}
export BRANCH_NAME=${BRANCH_NAME}
export ADD_BRANCH_NAME=${ADD_BRANCH_NAME}
export ENV=$BUILD_ENV
export BUILD_ENV=$BUILD_ENV
export BUILD_NUMBER=$BUILD_NUMBER
export BUILD_RESULT_KEY=$BUILD_RESULT_KEY
export BUILD_DEPLOY_VERSION=$BUILD_DEPLOY_VERSION
EOF

