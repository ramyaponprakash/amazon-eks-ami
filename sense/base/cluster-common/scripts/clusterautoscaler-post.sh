#!/bin/bash

AWS_ACCOUNT_ID="342446142760"
CLUSTER_NAME=""
NAMESPACE="cluster-common"
LOC=""

while getopts a:e:c:n:l flag
do
    case "${flag}" in
        a) AWS_ACCOUNT_ID=${OPTARG};;
        c) CLUSTER_NAME=${OPTARG};;
        n) NAMESPACE=${OPTARG};;
        l) LOC=${OPTARG};;
    esac
done

[[ -z "${CLUSTER_NAME}" ]] && echo "CLUSTER_NAME is required" && exit 1
[[ -z "${NAMESPACE}" ]] && echo "NAMESPACE is required" && exit 1

ROLE_NAME="EKS-AS-$(echo -n "$CLUSTER_NAME" | md5sum | awk '{ print $1 }')"
AUTOSCALER_ROLE_ARN="arn:aws:iam::$AWS_ACCOUNT_ID:role/$ROLE_NAME"

echo "Patching cluster-autoscaler"
# https://docs.aws.amazon.com/eks/latest/userguide/autoscaling.html

"${LOC}"kubectl annotate serviceaccount cluster-autoscaler-aws-cluster-autoscaler \
  -n "$NAMESPACE" \
  eks.amazonaws.com/role-arn="$AUTOSCALER_ROLE_ARN"

"${LOC}"kubectl patch deployment cluster-autoscaler-aws-cluster-autoscaler \
  -n "$NAMESPACE" \
  -p '{"spec":{"template":{"metadata":{"annotations":{"cluster-autoscaler.kubernetes.io/safe-to-evict": "false"}}}}}'

