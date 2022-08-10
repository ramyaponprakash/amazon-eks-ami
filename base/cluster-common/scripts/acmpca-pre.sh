#!/bin/bash

AWS_ACCOUNT_ID="342446142760"
CLUSTER_NAME=""
NAMESPACE="cluster-common"
RESOURCE_ID="*"
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

echo "Create secret access setups"

POLICY=$(cat <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "awspcaissuer",
            "Action": [
                "acm-pca:DescribeCertificateAuthority",
                "acm-pca:GetCertificate",
                "acm-pca:IssueCertificate"
            ],
          "Effect": "Allow",
          "Resource": "arn:aws:acm-pca:ap-southeast-1:$AWS_ACCOUNT_ID:certificate-authority/$RESOURCE_ID"
        }
    ]
}
EOF
)

POLICY_NAME="AllowACMPACAccess-$AWS_ACCOUNT_ID-$ENV"

"${LOC}"aws iam create-policy \
  --policy-name "$POLICY_NAME" \
  --policy-document "$POLICY" 2> /dev/null

POLICY_ARN=$(aws iam list-policies --query "Policies[?PolicyName==\`$POLICY_NAME\`].Arn" --output text)

ROLE_NAME="EKS-ACMPCA-$(echo -n "$CLUSTER_NAME" | md5sum | awk '{ print $1 }')"

"${LOC}"eksctl create iamserviceaccount \
  --cluster="$CLUSTER_NAME" \
  --namespace="$NAMESPACE" \
  --name=cert-manager-awspca-aws-privateca-issuer \
  --override-existing-serviceaccounts \
  --role-name "$ROLE_NAME" \
  --attach-policy-arn "$POLICY_ARN" \
  --approve 2> /dev/null


SA_PATCH=$(cat <<EOF
{
  "metadata": {
    "annotations": {
      "eks.amazonaws.com/role-arn": "arn:aws:iam::$AWS_ACCOUNT_ID:role/$ROLE_NAME"
    }
  }
}
EOF
)

"${LOC}"kubectl patch sa cert-manager \
  -n "$NAMESPACE" \
  -p "$SA_PATCH"

