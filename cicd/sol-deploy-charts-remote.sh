#!/bin/bash

CLUSTER_NAME=$1
AWS_ACCOUNT_ID=$2
VPC_ID=$3
K8S_VERSION=$4
# https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler#releases
# App version 1.26.2 == chart 9.28.0, k8 version 1.26.X but it works with 1.23+
AUTOSCALER_CHART_VERSION="9.28.0"
# AWS Load Balancer Controller v2.5.0+ requires Kubernetes 1.22+
# App version v2.5.0 == chart 1.5.0
LB_CTRL_CHART_VERSION="1.5.0"

if [[ $CLUSTER_NAME == "" ]]; then
  echo "CLUSTER_NAME required" && exit 1
fi
if [[ $AWS_ACCOUNT_ID == "" ]]; then
  echo "AWS_ACCOUNT_ID required" && exit 1
fi
if [[ $K8S_VERSION == "" ]]; then
  K8S_VERSION="1.25"
fi
if [[ $VPC_ID == "" ]]; then
  echo "VPC_ID required" && exit 1
fi

# Deploy the Cluster Autoscaler
# https://github.com/kubernetes/autoscaler/blob/master/charts/cluster-autoscaler/values.yaml
helm repo add autoscaler https://kubernetes.github.io/autoscaler
helm upgrade --install --debug cluster-autoscaler autoscaler/cluster-autoscaler --namespace kube-system --version=$AUTOSCALER_CHART_VERSION --set cluster_name=$CLUSTER_NAME \
  --set image.tag="v${K8S_VERSION}.0" \
  --set autoDiscovery.clusterName=$CLUSTER_NAME \
  --set awsRegion=ap-southeast-1 \
  --set cloudProvider=aws \
  --set extraArgs.balance-similar-node-groups=false \
  --set extraArgs.skip-nodes-with-system-pods=false \
  --set extraArgs.expander=least-waste \
  --set extraArgs.skip-nodes-with-local-storage=false \
  --set rbac.serviceAccount.annotations."eks\.amazonaws\.com/role-arn"="arn:aws:iam::$AWS_ACCOUNT_ID:role/$CLUSTER_NAME-cluster-autoscaler" \
  --set rbac.serviceAccount.name=cluster-autoscaler

# Deploy the Load Balancer Controller
helm repo add eks https://aws.github.io/eks-charts
helm upgrade --install lb-ctrl eks/aws-load-balancer-controller --namespace kube-system --version=$LB_CTRL_CHART_VERSION --set clusterName=$CLUSTER_NAME \
  --set vpcId=$VPC_ID \
  --set region=ap-southeast-1 \
  --set serviceAccount.name=aws-load-balancer-controller \
  --set serviceAccount.annotations."eks\.amazonaws\.com/role-arn"="arn:aws:iam::$AWS_ACCOUNT_ID:role/$CLUSTER_NAME-aws-lb-controller"

# TODO: condition execution by the value of http_proxy
# Applying proxy config after chart installation
kubectl patch -n kube-system -p '{ "spec": {"template":{ "spec": { "containers": [ { "name": "aws-cluster-autoscaler", "envFrom": [ { "configMapRef": {"name": "proxy-environment-variables"} } ] } ] } } } }' deployment cluster-autoscaler-aws-cluster-autoscaler
kubectl patch -n kube-system -p '{ "spec": {"template":{ "spec": { "containers": [ { "name": "aws-load-balancer-controller", "envFrom": [ { "configMapRef": {"name": "proxy-environment-variables"} } ] } ] } } } }' deployment lb-ctrl-aws-load-balancer-controller
