#!/bin/bash

AWS_ACCOUNT_ID="342446142760"
CLUSTER_NAME=""
NAMESPACE="cluster-common"
ENV=dev
LOC=""

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

eksctl utils associate-iam-oidc-provider --region=ap-southeast-1 --cluster=${CLUSTER_NAME} --approve 2> /dev/null

echo "Create secret access setups"

POLICY=$(cat <<EOF
{
    "Version": "2012-10-17",
    "Statement": [ {
        "Effect": "Allow",
        "Action": [
            "secretsmanager:GetResourcePolicy",
            "secretsmanager:GetSecretValue",
            "secretsmanager:DescribeSecret",
            "secretsmanager:ListSecretVersionIds"
        ],
        "Resource": ["arn:aws:secretsmanager:ap-southeast-1:$AWS_ACCOUNT_ID:secret:*"]
    } ]
}
EOF
)

POLICY_NAME="AllowEKSSecretManagerAccess-$AWS_ACCOUNT_ID-$ENV"

"${LOC}"aws iam create-policy \
  --policy-name "$POLICY_NAME" \
  --policy-document "$POLICY" 2> /dev/null

POLICY_ARN=$(aws iam list-policies --query "Policies[?PolicyName==\`$POLICY_NAME\`].Arn" --output text)

ROLE_NAME="EKS-SEC-$(echo -n "$CLUSTER_NAME" | md5sum | awk '{ print $1 }')"

"${LOC}"eksctl create iamserviceaccount \
  --cluster="$CLUSTER_NAME" \
  --namespace="$NAMESPACE" \
  --name=secrets-access-sa \
  --override-existing-serviceaccounts \
  --role-name "$ROLE_NAME" \
  --attach-policy-arn "$POLICY_ARN" \
  --approve 2> /dev/null

