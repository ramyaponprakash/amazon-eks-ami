#!/bin/bash

DATACENTER_NAME=$(terraform output -json -state=terraform/terraform.tfstate datacenter_name | jq -r .)
AWS_ACCOUNT_ID=$(terraform output -json -state=terraform/terraform.tfstate aws_account_id | jq -r .)
AWS_PARTITION=$(terraform output -json -state=terraform/terraform.tfstate aws_partition_name | jq -r .)
K8S_VERSION=$(terraform output -json -state=terraform/terraform.tfstate k8s-version | jq -r .)

AUTOSCALER_VERSION="v${K8S_VERSION}.0"

if [[ $GCP_REGISTRY == "" ]]; then
  GCP_REGISTRY="gcr.io/gcp-maas-prod"
fi

if ! kubectl get secret -n kube-system gcr-reg-secret > /dev/null; then
  echo "error: registry secret 'gcr-reg-secret' must exist in kube-system namespace" && exit 1
fi
IMAGE_REPO_LB_CTRL="--set image.repository=${GCP_REGISTRY}/aws-load-balancer-controller --set imagePullSecrets[0].name=gcr-reg-secret "

# Deploy the Cluster Autoscaler
helm upgrade --install cluster-autoscaler ../charts/cluster-autoscaler --namespace kube-system ${IMAGE_REPO_AUTOSCALER} --set cluster_name=$DATACENTER_NAME \
  --set serviceAccount.annotations."eks\.amazonaws\.com/role-arn"="arn:${AWS_PARTITION}:iam::${AWS_ACCOUNT_ID}:role/${DATACENTER_NAME}-cluster-autoscaler" \
  --set image.tag=${AUTOSCALER_VERSION}

# Deploy the Load Balancer Controller
helm upgrade --install lb-ctrl ../charts/aws-load-balancer-controller --namespace kube-system ${IMAGE_REPO_LB_CTRL} --set clusterName=$DATACENTER_NAME --set serviceAccount.name=aws-load-balancer-controller \
  --set serviceAccount.annotations."eks\.amazonaws\.com/role-arn"="arn:${AWS_PARTITION}:iam::${AWS_ACCOUNT_ID}:role/${DATACENTER_NAME}-aws-lb-controller" --set enableNLBRestrictedSGRules=true

# this decreases the number of IPs reserved for each worker node
kubectl set env ds aws-node -n kube-system WARM_IP_TARGET=1
kubectl set env ds aws-node -n kube-system WARM_ENI_TARGET=0
