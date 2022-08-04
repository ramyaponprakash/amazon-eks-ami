#!/bin/bash

CHART_NAME="sense-frontend"
IMAGE_TAG="latest"

# load env vars
TEMP_FOLDER=$1
if [[ -z "${TEMP_FOLDER}" ]]; then
  TEMP_FOLDER=/home/bamboo/tmp
fi
. ${TEMP_FOLDER}/envvars

./cicd/bamboo/base-deploy-helmfile.sh $CHART_NAME $ENV $CLUSTER_NAME $IMAGE_TAG