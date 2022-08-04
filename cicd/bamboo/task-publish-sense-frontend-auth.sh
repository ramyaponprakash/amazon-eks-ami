#!/bin/bash

CHART_NAME="sense-frontend-auth"

# load env vars
TEMP_FOLDER=$1
if [[ -z "${TEMP_FOLDER}" ]]; then
  TEMP_FOLDER=/home/bamboo/tmp
fi
. ${TEMP_FOLDER}/envvars

./cicd/bamboo/base-publish-chart.sh $CHART_NAME $ENV $CLUSTER_NAME