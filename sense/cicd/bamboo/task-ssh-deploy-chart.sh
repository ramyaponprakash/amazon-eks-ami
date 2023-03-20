#!/bin/bash

ARTIFACT_FOLDER=$1
CHART_NAME=$2
IMAGE_TAG=$3

if [ -f ${ARTIFACT_FOLDER}/envvars ]; then
    . ${ARTIFACT_FOLDER}/envvars
fi

BUILD_ENV=$BUILD_ENV
CLUSTER_NAME=$CLUSTER_NAME

[[ -z "${BUILD_ENV}" ]] && echo "BUILD_ENV is required" && exit 1
[[ -z "${CLUSTER_NAME}" ]] && echo "CLUSTER_NAME is required" && exit 1
[[ -z "${CHART_NAME}" ]] && echo "CHART_NAME is required" && exit 1

echo "Started deploy chart with ENV=$ENV, CLUSTER_NAME=$CLUSTER_NAME, CHART_NAME=$CHART_NAME, IMAGE_TAG=$IMAGE_TAG"

if [[ -z "${IMAGE_TAG}" ]]; then
  helmfile -e "$BUILD_ENV" -f ./base/"$CHART_NAME"/helmfile.yaml apply || exit 1
else
  helmfile -e "$BUILD_ENV" -f ./base/"$CHART_NAME"/helmfile.yaml apply --set image.tag="$IMAGE_TAG" || exit 1
fi

echo "deploy chart '$CHART_NAME' in cluster '$CLUSTER_NAME' - done!"
