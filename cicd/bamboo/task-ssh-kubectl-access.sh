#!/bin/bash

ARTIFACT_FOLDER=$1
if [ -f ${ARTIFACT_FOLDER}/envvars ]; then
    . ${ARTIFACT_FOLDER}/envvars
fi

[[ -z "${CLUSTER_NAME}" ]] && echo "CLUSTER_NAME is required" && exit 1
[[ -z "${ROLE_ARN}" ]] && echo "ROLE_ARN is required" && exit 1

# update kubeconfig to access cluster by the assumed role
echo "Set assumed role access for kubectl $AWS_DEFAULT_REGION - $ROLE_ARN - $CLUSTER_NAME"
aws --version
aws sts get-caller-identity
aws eks --region "$AWS_DEFAULT_REGION" update-kubeconfig --name "$CLUSTER_NAME" --role-arn "$ROLE_ARN"
kubectl get namespace
echo "Set assumed role access for kubectl - done!"