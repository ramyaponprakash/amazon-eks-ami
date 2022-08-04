#!/bin/bash

CHART_NAME="monitoring"

# load env vars
TEMP_FOLDER=$1
if [[ -z "${TEMP_FOLDER}" ]]; then
  TEMP_FOLDER=/home/bamboo/tmp
fi
. ${TEMP_FOLDER}/envvars

./cicd/bamboo/base-deploy-helmfile.sh $CHART_NAME $ENV $CLUSTER_NAME