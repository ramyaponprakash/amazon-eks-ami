#!/bin/bash

CLUSTER_NAME=""
NAMESPACE="cluster-common"
LOC="/tmp/"

while getopts c:n:l flag
do
    case "${flag}" in
        c) CLUSTER_NAME=${OPTARG};;
        n) NAMESPACE=${OPTARG};;
        l) LOC=${OPTARG};;
    esac
done

[[ -z "${CLUSTER_NAME}" ]] && echo "CLUSTER_NAME is required" && exit 1
[[ -z "${NAMESPACE}" ]] && echo "NAMESPACE is required" && exit 1

echo "Patching cluster resource to allow helm control"

HELM_CONTROL_PATCH=$(cat <<EOF
{
  "metadata": {
    "labels": {
      "app.kubernetes.io/managed-by": "Helm"
    },
    "annotations": {
      "meta.helm.sh/release-name": "$NAMESPACE",
      "meta.helm.sh/release-namespace": "$NAMESPACE"
    }
  }
}
EOF
)

"${LOC}"kubectl patch configmap aws-auth \
  -n kube-system \
  -p "$HELM_CONTROL_PATCH"

"${LOC}"eksctl utils associate-iam-oidc-provider \
  --region=ap-southeast-1 \
  --cluster="$CLUSTER_NAME" --approve 2> /dev/null

aws eks describe-cluster --name "$CLUSTER_NAME" --query "cluster.identity.oidc.issuer" --output text

