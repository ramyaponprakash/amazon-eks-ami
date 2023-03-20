#!/bin/bash

# load env vars
TEMP_FOLDER=$1
if [[ -z "${TEMP_FOLDER}" ]]; then
  TEMP_FOLDER=/home/bamboo/tmp
fi
. ${TEMP_FOLDER}/envvars

# update kubeconfig to access cluster by the assumed role
# TODO: remove tmp awscli v2 once AMI is ready
echo "Set assumed role access for kubectl"
/tmp/aws --version
/tmp/aws sts get-caller-identity
echo "$AWS_DEFAULT_REGION - $ROLE_ARN - $CLUSTER_NAME"
/tmp/aws eks --region "$AWS_DEFAULT_REGION" update-kubeconfig --name "$CLUSTER_NAME" --role-arn "$ROLE_ARN"

PREV_AWS="command: aws"
NEW_AWS="command: /tmp/aws"
KUBE_CONFIG="/home/bamboo/.kube/config"
KUBE_TEMP="/home/bamboo/.kube/temp"

sed --expression "s@$PREV_AWS@$NEW_AWS@" $KUBE_CONFIG > $KUBE_TEMP
mv $KUBE_TEMP $KUBE_CONFIG
chmod 600 $KUBE_CONFIG

/tmp/kubectl get namespace

echo "Set assumed role access for kubectl - done!"