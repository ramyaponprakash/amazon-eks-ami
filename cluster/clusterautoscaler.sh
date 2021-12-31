#!/bin/bash

AWS_ACCOUNT_ID="342446142760"
AUTOSCALER_POLICY="AmazonEKSClusterAutoscalerPolicy"
CLUSTER_NAME="sdx-eks-green-cluster"
SYSTEM_NAMESPACE="kube-system"

# NOTE: it will go thru CloudFormation
eksctl create iamserviceaccount \
  --cluster=sdx-eks-green-cluster \
  --namespace=kube-system \
  --name=dev-cluster-autoscaler \
  --attach-policy-arn=arn:aws:iam::342446142760:policy/AmazonEKSClusterAutoscalerPolicy \
  --override-existing-serviceaccounts \
  --approve

kubectl annotate serviceaccount cluster-autoscaler \
  -n kube-system \
  eks.amazonaws.com/role-arn=arn:aws:iam::342446142760:role/AmazonEKSClusterAutoscalerRole

kubectl patch deployment cluster-autoscaler \
  -n kube-system \
  -p '{"spec":{"template":{"metadata":{"annotations":{"cluster-autoscaler.kubernetes.io/safe-to-evict": "false"}}}}}'

#https://docs.aws.amazon.com/eks/latest/userguide/autoscaling.html
#https://www.kubecost.com/kubernetes-autoscaling/kubernetes-cluster-autoscaler/
