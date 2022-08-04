#!/bin/bash

LOC="/tmp/"
CHART_NAME=$1
ENV=$2
CLUSTER_NAME=$3
TAG=$4

[[ -z "${CHART_NAME}" ]] && echo "$CHART_NAME is required" && exit 1
[[ -z "${ENV}" ]] && echo "ENV is required" && exit 1
[[ -z "${CLUSTER_NAME}" ]] && echo "CLUSTER_NAME is required" && exit 1

echo "deploy $CHART_NAME in $CLUSTER_NAME"

if [[ -z "${TAG}" ]]; then
  "${LOC}"/helmfile -e "$ENV" -f ./base/"$CHART_NAME"/helmfile.yaml apply || exit 1
else
  "${LOC}"/helmfile -e "$ENV" -f ./base/"$CHART_NAME"/helmfile.yaml apply --set image.tag="$TAG" || exit 1
fi

echo "deploy $CHART_NAME in $CLUSTER_NAME - done!"