#!/bin/bash

CLUSTER_NAME=$1

if [[ -z "${CLUSTER_NAME}" ]]; then
  echo "CLUSTER_NAME requires" && exit 1
fi

aws eks --region ap-southeast-1 update-kubeconfig --name $CLUSTER_NAME
aws eks describe-cluster --name "$CLUSTER_NAME" --query "cluster.identity.oidc.issuer" --output text

echo "decreasing the number of IPs reserved for each worker node"
kubectl set env ds aws-node -n kube-system WARM_IP_TARGET=1
kubectl set env ds aws-node -n kube-system WARM_ENI_TARGET=0

kubectl create ns solace-cloud

echo "patching for http_proxy"
kubectl patch -n kube-system -p '{ "spec": {"template":{ "spec": { "containers": [ { "name": "aws-node", "envFrom": [ { "configMapRef": {"name": "proxy-environment-variables"} } ] } ] } } } }' daemonset aws-node
kubectl patch -n kube-system -p '{ "spec": {"template":{ "spec": { "containers": [ { "name": "kube-proxy", "envFrom": [ { "configMapRef": {"name": "proxy-environment-variables"} } ] } ] } } } }' daemonset kube-proxy
kubectl patch -n kube-system -p '{ "spec": {"template":{ "spec": { "containers": [ { "name": "coredns", "envFrom": [ { "configMapRef": {"name": "proxy-environment-variables"} } ] } ] } } } }' deployment coredns

# After chart
kubectl patch -n kube-system -p '{ "spec": {"template":{ "spec": { "containers": [ { "name": "aws-cluster-autoscaler", "envFrom": [ { "configMapRef": {"name": "proxy-environment-variables"} } ] } ] } } } }' deployment cluster-autoscaler-aws-cluster-autoscaler

# TODO: aws loadbalancer controller test