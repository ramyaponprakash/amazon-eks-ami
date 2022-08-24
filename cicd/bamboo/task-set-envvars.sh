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

BRANCH="${bamboo_repository_branch_name}" # "${bamboo.repository.branch_name}"
BRANCH_NAME=$(echo $BRANCH | sed -e 's/\//-/g')
ENV=""
ROLE=""
BUILD_ENV="${bamboo_BUILD_ENV}" # "${bamboo.BUILD_ENV}"
ADD_BRANCH_NAME="${ADD_BRANCH_NAME}" # "${bamboo.ADD_BRANCH_NAME}"
BUILD_NUMBER="${bamboo_buildNumber}" # ${bamboo.buildNumber}
BUILD_RESULT_KEY="${bamboo_buildResultKey}" # ${bamboo.buildResultKey}
BUILD_DEPLOY_VERSION="${bamboo_deploy_version}"

TEMP_FOLDER=$1
if [[ -z "${TEMP_FOLDER}" ]]; then
  TEMP_FOLDER=/home/bamboo/tmp
fi
mkdir -p $TEMP_FOLDER

# Switch AWS Account Id and ENV base on branch name. Wont deploy master branch.
if [[ "${BRANCH_NAME}" == 'release-'* ]] || [[ "${BRANCH_NAME}" == "${ADD_BRANCH_NAME}" ]] && [[ "${BUILD_ENV}" != "dev" ]]; then
    if [[ "${BUILD_ENV}" == "prod" ]]; then
        ENV=prod
        THIS_AWS_ACC=$PRD_AWS_ACC
        ROLE=u-ship
    elif [[ "${BUILD_ENV}" == "intra" ]]; then
        ENV=intra
        THIS_AWS_ACC=$PRD_AWS_ACC
        ROLE=u-ship
    else
        ENV=qa
        BUILD_ENV=qa
        THIS_AWS_ACC=$DEV_AWS_ACC
        ROLE=forBamboo
    fi
elif [[ "${BRANCH_NAME}" == 'develop' ]] || [[ "${BRANCH_NAME}" == "${ADD_BRANCH_NAME}" ]]; then
    ENV=dev
    BUILD_ENV=dev
    THIS_AWS_ACC=$DEV_AWS_ACC
    ROLE=forBamboo
else
    echo "Invalid branch ${BRANCH_NAME}"
    exit 99
fi

ROLE_ARN="arn:aws:iam::${THIS_AWS_ACC}:role/${ROLE}"
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
export BRANCH_NAME=${BRANCH_NAME}
export ADD_BRANCH_NAME=${ADD_BRANCH_NAME}
export ENV=$ENV
export BUILD_ENV=$BUILD_ENV
export BUILD_NUMBER=$BUILD_NUMBER
export BUILD_RESULT_KEY=$BUILD_RESULT_KEY
export BUILD_DEPLOY_VERSION=$BUILD_DEPLOY_VERSION
EOF

