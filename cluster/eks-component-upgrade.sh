#!/bin/bash

VPC_ID="vpc-09a58d6d"
CLUSTER_NAME="sdx-eks-green-cluster"
KUBECTL_VER="1.21.2/2021-07-05"
SYSTEM_NAMESPACE="kube-system"
METRICS_SERVER_VER="3.7.0"
DASHBOARD_VER="v2.4.0"
AWS_LB_CTR_CHART_VER="v1.3.3"
NGINX_ING_CHART_VER="4.0.13"

set -e

echo "Listing all installed releases"
helm list --all-namespaces

echo "Updating helm repo"
helm repo add eks https://aws.github.io/eks-charts
helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/
helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
# helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update


# === Metrics-server install/upgrade ===
echo "Installing Metrics Server - version: ${METRICS_SERVER_VER}"
# NOTE: the helm chart is not supporting namespace change yet. so will use manifest
#helm upgrade --install metrics-server metrics-server/metrics-server --version=${METRICS_SERVER_VER} --set namespace=${SYSTEM_NAMESPACE}
kubectl apply -f "https://github.com/kubernetes-sigs/metrics-server/releases/download/metrics-server-helm-chart-${METRICS_SERVER_VER}/components.yaml"
kubectl get deployment metrics-server -n ${SYSTEM_NAMESPACE} -o wide
kubectl top nodes
echo "Installing Metrics Server - finished!"


# === Dashboard install/upgrade ===
echo "Installing Dashboard - version: ${DASHBOARD_VER}"
# NOTE: the helm chart is not supporting namespace change yet. so will use manifest
#helm upgrade --install kubernetes-dashboard/kubernetes-dashboard \
#  --version=${DASHBOARD_VER} \
#  --name kubernetes-dashboard \
#  --set service.externalPort=443 \
#  --set resources.limits.cpu=200m
kubectl apply -f "https://raw.githubusercontent.com/kubernetes/dashboard/${DASHBOARD_VER}/aio/deploy/recommended.yaml"
kubectl get deployment -n kubernetes-dashboard -o wide
echo "Installing Dashboard - finished!"


# === AWS load balancer controller install/upgrade ===
# refer https://docs.aws.amazon.com/eks/latest/userguide/aws-load-balancer-controller.html
echo "Installing AWS load balancer controller - version: ${AWS_LB_CTR_CHART_VER}"
kubectl apply -k "github.com/aws/eks-charts/stable/aws-load-balancer-controller/crds?ref=master"
helm upgrade --install aws-load-balancer-controller eks/aws-load-balancer-controller \
  --version=${AWS_LB_CTR_CHART_VER} \
  -n ${SYSTEM_NAMESPACE} \
  --set clusterName=${CLUSTER_NAME} \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller \
  --set region=ap-southeast-1 \
  --set vpcId=${VPC_ID}
kubectl get deployment aws-load-balancer-controller -n ${SYSTEM_NAMESPACE} -o wide
echo "Installing AWS load balancer controller - finished!"


# === Ingress install/upgrade ===
echo "Installing Nginx Ingress Controllers - chart version: ${NGINX_ING_CHART_VER}"
# TODO: use yaml in repo
#helm upgrade --install ingress-nginx-external ingress-nginx/ingress-nginx \
#  --version=${NGINX_ING_CHART_VER} \
#  -n ingress-nginx --create-namespace \
#  -f ./values_nginx_ingress.yaml
#
#helm upgrade --install ingress-nginx-internal ingress-nginx/ingress-nginx \
#  --version=${NGINX_ING_CHART_VER} \
#  -n ingress-nginx \
#  -f ./values_internal_nginx_ingress.yaml
echo "Installing Nginx Ingress Controllers - finished!"
# kubectl get ValidatingWebhookConfiguration


# === Jaeger install/upgrade ===
# TODO
#helm upgrade --install aws-load-balancer-controller eks/aws-load-balancer-controller \
#  --version=v1.3.3 \
#  -n kube-system \
#  --set clusterName=sdx-eks-green-cluster \
#  --set serviceAccount.create=false \
#  --set serviceAccount.name=aws-load-balancer-controller \
#  --set region=ap-southeast-1 \
#  --set vpcId=vpc-09a58d6d