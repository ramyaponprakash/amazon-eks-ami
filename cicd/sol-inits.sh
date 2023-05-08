#!/bin/bash

CLUSTER_NAME=$1

if [[ -z "${CLUSTER_NAME}" ]]; then
  echo "CLUSTER_NAME required" && exit 1
fi

aws eks --region ap-southeast-1 update-kubeconfig --name $CLUSTER_NAME
EKS_OIDC_ID=$(aws eks describe-cluster --name "$CLUSTER_NAME" --query "cluster.identity.oidc.issuer" --output text | cut -d '/' -f 5)
OIDC_OBJ=$(aws iam list-open-id-connect-providers | grep "$EKS_OIDC_ID" | cut -d "/" -f4)
if [[ -z "${OIDC_OBJ}" ]]; then
  eksctl utils associate-iam-oidc-provider --cluster "${CLUSTER_NAME}" --approve
fi


echo "decreasing the number of IPs reserved for each worker node"
kubectl set env ds aws-node -n kube-system WARM_IP_TARGET=1
kubectl set env ds aws-node -n kube-system WARM_ENI_TARGET=0

# TODO: condition execution by the value of http_proxy
echo "patching for http_proxy"
kubectl patch -n kube-system -p '{ "spec": {"template":{ "spec": { "containers": [ { "name": "aws-node", "envFrom": [ { "configMapRef": {"name": "proxy-environment-variables"} } ] } ] } } } }' daemonset aws-node
kubectl patch -n kube-system -p '{ "spec": {"template":{ "spec": { "containers": [ { "name": "kube-proxy", "envFrom": [ { "configMapRef": {"name": "proxy-environment-variables"} } ] } ] } } } }' daemonset kube-proxy
kubectl patch -n kube-system -p '{ "spec": {"template":{ "spec": { "containers": [ { "name": "coredns", "envFrom": [ { "configMapRef": {"name": "proxy-environment-variables"} } ] } ] } } } }' deployment coredns
