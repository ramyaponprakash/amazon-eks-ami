#!/bin/bash

ARTIFACT_FOLDER=$1

[[ -z "${bamboo_CLUSTER_NAME}" ]] && echo "CLUSTER_NAME is required" && exit 1
[[ -z "${bamboo_ROLE_ARN}" ]] && echo "ROLE_ARN is required" && exit 1

cat <<EOF > $ARTIFACT_FOLDER/envvars
export AWS_ACC="${bamboo_DEV_AWS_ACC}"
export AWS_DEFAULT_REGION="ap-southeast-1"
export ROLE_ARN="${bamboo_ROLE_ARN}"
export BUILD_ENV="${bamboo_BUILD_ENV}"
export ADD_BRANCH_NAME="${bamboo_ADD_BRANCH_NAME}"
export CLUSTER_NAME="${bamboo_CLUSTER_NAME}"
export BUILD_NUMBER="${bamboo_buildNumber}"
export BUILD_RESULT_KEY="${bamboo_buildResultKey}"
export BUILD_DEPLOY_VERSION="${bamboo_deploy_version}"
export HELM_BINARY=helm
EOF
