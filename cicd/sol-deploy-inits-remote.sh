#!/bin/bash

CLUSTER_NAME=$1
AWS_ACCOUNT_ID=$2
K8S_VERSION=$3

if [[ $K8S_VERSION == "" ]]; then
  K8S_VERSION="1.23"
fi

# TODO: remove this
 CLUSTER_NAME=solace-poc-cluster
 AWS_ACCOUNT_ID=342446142760

AUTOSCALER_VERSION="v${K8S_VERSION}.0"
ALBC_VERSION="v2.4.1-nlb"

aws eks update-kubeconfig --region ap-southeast-1 --name $CLUSTER_NAME

if ! kubectl get secret -n kube-system gcr-reg-secret > /dev/null; then
  echo "error: registry secret 'gcr-reg-secret' must exist in kube-system namespace" && exit 1
fi
IMAGE_REPO_LB_CTRL="--set image.repository=gcr.io/gcp-maas-prod/aws-load-balancer-controller --set imagePullSecrets[0].name=gcr-reg-secret "

# Deploy the Cluster Autoscaler
# https://github.com/kubernetes/autoscaler/blob/master/charts/cluster-autoscaler/values.yaml
helm repo add autoscaler https://kubernetes.github.io/autoscaler
helm upgrade --install cluster-autoscaler autoscaler/cluster-autoscaler --namespace kube-system ${IMAGE_REPO_AUTOSCALER} --set cluster_name=$CLUSTER_NAME \
  --set image.tag=${AUTOSCALER_VERSION} \
  --set autoDiscovery.clusterName=$CLUSTER_NAME \
  --set awsRegion=ap-southeast-1 \
  --set cloudProvider=aws \
  --set extraArgs.balance-similar-node-groups=true \
  --set extraArgs.skip-nodes-with-system-pods=false \
  --set extraArgs.expander=least-waste \
  --set extraArgs.skip-nodes-with-local-storage=false \
  --set rbac.serviceAccount.annotations."eks\.amazonaws\.com/role-arn"="arn:aws:iam::${AWS_ACCOUNT_ID}:role/${CLUSTER_NAME}-cluster-autoscaler" \
  --set rbac.serviceAccount.name=cluster-autoscaler

# Deploy the Load Balancer Controller
helm repo add eks https://aws.github.io/eks-charts
helm upgrade --install lb-ctrl eks/aws-load-balancer-controller --namespace kube-system ${IMAGE_REPO_LB_CTRL} --set clusterName=$CLUSTER_NAME --set serviceAccount.name=aws-load-balancer-controller \
  --set serviceAccount.annotations."eks\.amazonaws\.com/role-arn"="arn:aws:iam::${AWS_ACCOUNT_ID}:role/${CLUSTER_NAME}-aws-lb-controller" --set enableNLBRestrictedSGRules=true \
  --set image.tag=${ALBC_VERSION}

# this decreases the number of IPs reserved for each worker node
kubectl set env ds aws-node -n kube-system WARM_IP_TARGET=1
kubectl set env ds aws-node -n kube-system WARM_ENI_TARGET=0

kubectl create ns solace-cloud
kubectl delete sc gp2