#!/bin/bash

AWS_ACCOUNT_ID="342446142760"
CLUSTER_NAME=""
NAMESPACE="cluster-common"
ENV=dev
LOC="/tmp/"

while getopts a:e:c:n:l flag
do
    case "${flag}" in
        a) AWS_ACCOUNT_ID=${OPTARG};;
        e) ENV=${OPTARG};;
        c) CLUSTER_NAME=${OPTARG};;
        n) NAMESPACE=${OPTARG};;
        l) LOC=${OPTARG};;
    esac
done

[[ -z "${CLUSTER_NAME}" ]] && echo "CLUSTER_NAME is required" && exit 1
[[ -z "${NAMESPACE}" ]] && echo "NAMESPACE is required" && exit 1

echo "Create aws load balance controller setups"
# https://docs.aws.amazon.com/eks/latest/userguide/aws-load-balancer-controller.html

AWS_LB_CTR_APP_VERSION="v2.4.2"

curl -s -L -o iam_policy.json "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/$AWS_LB_CTR_APP_VERSION/docs/install/iam_policy.json"

"${LOC}"aws iam create-policy \
  --policy-name AWSLoadBalancerControllerIAMPolicy \
  --policy-document file://iam_policy.json 2> /dev/null

rm iam_policy.json

ROLE_NAME="EKS-LBC-$(echo -n "$CLUSTER_NAME" | md5sum | awk '{ print $1 }')"

"${LOC}"eksctl create iamserviceaccount \
  --cluster="$CLUSTER_NAME" \
  --namespace="$NAMESPACE" \
  --name=aws-load-balancer-controller \
  --override-existing-serviceaccounts \
  --role-name "$ROLE_NAME" \
  --attach-policy-arn "arn:aws:iam::$AWS_ACCOUNT_ID:policy/AWSLoadBalancerControllerIAMPolicy" \
  --approve 2> /dev/null

"${LOC}"kubectl apply -k "github.com/aws/eks-charts/stable/aws-load-balancer-controller/crds?ref=master"
