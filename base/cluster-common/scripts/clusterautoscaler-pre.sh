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

echo "Create cluster autoscaler setups"
# https://docs.aws.amazon.com/eks/latest/userguide/autoscaling.html

POLICY=$(cat <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "autoscaling:SetDesiredCapacity",
                "autoscaling:TerminateInstanceInAutoScalingGroup"
            ],
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "aws:ResourceTag/k8s.io/cluster-autoscaler/$CLUSTER_NAME": "owned"
                }
            }
        },
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": [
                "autoscaling:DescribeAutoScalingInstances",
                "autoscaling:DescribeAutoScalingGroups",
                "ec2:DescribeLaunchTemplateVersions",
                "autoscaling:DescribeTags",
                "autoscaling:DescribeLaunchConfigurations"
            ],
            "Resource": "*"
        }
    ]
}
EOF
)

POLICY_NAME="AmazonEKSClusterAutoscalerPolicy-$CLUSTER_NAME"

aws iam create-policy \
    --policy-name "$POLICY_NAME" \
    --policy-document "$POLICY" 2> /dev/null

POLICY_ARN=$(aws iam list-policies --query "Policies[?PolicyName==\`$POLICY_NAME\`].Arn" --output text)

ROLE_NAME="EKS-AS-$(echo -n "$CLUSTER_NAME" | md5sum | awk '{ print $1 }')"

"${LOC}"eksctl create iamserviceaccount \
  --region=ap-southeast-1 \
  --cluster="$CLUSTER_NAME" \
  --namespace="$NAMESPACE" \
  --name=cluster-autoscaler-aws-cluster-autoscaler \
  --role-name="$ROLE_NAME" \
  --attach-policy-arn="$POLICY_ARN" \
  --override-existing-serviceaccounts \
  --approve 2> /dev/null
