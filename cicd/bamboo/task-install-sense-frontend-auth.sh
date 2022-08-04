#!/bin/bash

CHART_NAME="sense-frontend-auth"
#IMAGE_TAG="latest"
IMAGE_TAG="feature-dev-v2-1" # TODO: modify this

# load env vars
TEMP_FOLDER=$1
if [[ -z "${TEMP_FOLDER}" ]]; then
  TEMP_FOLDER=/home/bamboo/tmp
fi
. ${TEMP_FOLDER}/envvars

./cicd/bamboo/base-deploy-helmfile.sh $CHART_NAME $ENV $CLUSTER_NAME $IMAGE_TAG