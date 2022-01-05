#!/bin/bash

KUBECTL_VER="1.21.2/2021-07-05"
HELM_VER="v3.7.2"

install_command_if_not_exist() {
  if ! command -v $1 &> /dev/null
  then
    $2
  else
    echo "The cli '$1' already exist, skip installing"
  fi
}

install_kubectl() {
  echo "Installing kubectl - version: ${KUBECTL_VER}"
  curl -o kubectl "https://amazon-eks.s3.us-west-2.amazonaws.com/${KUBECTL_VER}/bin/linux/amd64/kubectl"
  curl -o kubectl.sha256 "https://amazon-eks.s3.us-west-2.amazonaws.com/${KUBECTL_VER}/bin/linux/amd64/kubectl.sha256"
  openssl sha1 -sha256 kubectl
  chmod +x ./kubectl
  mv ./kubectl /usr/local/bin/kubectl
  kubectl version --short --client
}

install_helm() {
  echo "Installing helm - version: ${HELM_VER}"
  curl -o helm.tar.gz "https://get.helm.sh/helm-${HELM_VER}-linux-amd64.tar.gz"
  curl -o helm.tar.gz.sha256 "https://get.helm.sh/helm-${HELM_VER}-linux-amd64.tar.gz.sha256sum"
  openssl sha1 -sha256 helm.tar.gz
  tar -zxvf helm.tar.gz
  chmod +x ./linux-amd64/helm
  mv ./linux-amd64/helm /usr/local/bin/helm
  rm helm.tar.*
  chmod 600 ~/.kube/config
  helm version
}

install_command_if_not_exist kubectl install_kubectl
install_command_if_not_exist helm install_helm