#!/bin/sh

ns=solace-cloud

kubectl -n $ns delete cm solace-validation
kubectl -n $ns delete sa solace-validation
kubectl delete clusterrole solace-validation-cluster-role
kubectl delete clusterrolebinding solace-validation-cluster-role-binding
kubectl -n $ns  delete role solace-validation-role
kubectl -n $ns delete rolebinding solace-validation-role-binding
kubectl -n $ns delete job solace-validation

