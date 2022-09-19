#!/bin/bash
# Create ${bamboo.build.working.directory}/envvars file
# containing key ENV vars for all steps to read.
# AWS_SESSION_TOKEN duration set to 3600 seconds.

aws configure set default.region ap-southeast-1
aws configure set default.output json
rm -f $HOME/.docker/config.json

ENV="${bamboo_ENV}"
BUILD_ENV="${bamboo_BUILD_ENV}"
ROLE_ARN="${bamboo_ROLE_ARN}"

TEMP_FOLDER=$1
if [[ -z "${TEMP_FOLDER}" ]]; then
  TEMP_FOLDER=/home/bamboo/tmp
fi
mkdir -p $TEMP_FOLDER

temp_role=$(aws sts assume-role \
    --duration-seconds 3600 \
    --role-arn "${ROLE_ARN}" \
    --role-session-name "eks_deploy")

cat <<EOF > ${TEMP_FOLDER}/envvars
export AWS_DEFAULT_REGION=ap-southeast-1
export AWS_ACCESS_KEY_ID=$(echo $temp_role | jq .Credentials.AccessKeyId | xargs)
export AWS_SECRET_ACCESS_KEY=$(echo $temp_role | jq .Credentials.SecretAccessKey | xargs)
export AWS_SESSION_TOKEN=$(echo $temp_role | jq .Credentials.SessionToken | xargs)
export ROLE_ARN=$ROLE_ARN
export ENV=$ENV
export BUILD_ENV=$BUILD_ENV
EOF

