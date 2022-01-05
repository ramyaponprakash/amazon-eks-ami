#!/bin/bash

helm upgrade --install cluster ./cluster --namespace=kube-system --create-namespace
helm dependency list cluster

helm upgrade --install ingress-nginx ./ingress-nginx --namespace=ingress-nginx --create-namespace

helm upgrade --install monitoring ./monitoring --namespace=monitoring --create-namespace
helm dependency list monitoring

helm upgrade --install sense ./sense --namespace=sense --create-namespace