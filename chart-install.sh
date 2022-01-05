#!/bin/bash

FRONTEND_TAG=latest
BACKEND_TAG=latest
BASE_COMMAND="helm upgrade --install --create-namespace"

while getopts f:b:d flag
do
    case "${flag}" in
        f) FRONTEND_TAG=${OPTARG};;
        b) BACKEND_TAG=${OPTARG};;
        d) BASE_COMMAND="${BASE_COMMAND} --dry-run";;
    esac
done

$BASE_COMMAND cluster ./cluster --namespace=kube-system
helm dependency list cluster

$BASE_COMMAND ingress-nginx ./ingress-nginx --namespace=ingress-nginx

$BASE_COMMAND monitoring ./monitoring --namespace=monitoring
helm dependency list monitoring

echo "Deploying sense with tag frontend=${FRONTEND_TAG}, backend=${BACKEND_TAG}"
$BASE_COMMAND sense ./sense --namespace=sense \
  --set image.frontend.tag=${FRONTEND_TAG} \
  --set image.backend.tag=${BACKEND_TAG}

helm list --all-namespaces