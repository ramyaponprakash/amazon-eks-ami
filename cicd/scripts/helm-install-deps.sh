#!/bin/bash

set -o pipefail
set -o nounset
set -o errexit

# https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html
KUBECTL_VER=$1

# https://github.com/helm/helm/releases
# https://helm.sh/docs/topics/version_skew/
HELM_VER=$2
HELMFILE_VER=$3

install_kubectl() {
  curl -L -s -o kubectl "https://s3.us-west-2.amazonaws.com/amazon-eks/${KUBECTL_VER}/bin/linux/amd64/kubectl"
  chmod +x kubectl && sudo mv kubectl /usr/local/bin/
  kubectl version --client
}

install_helm() {
  curl -L -s -o helm.tar.gz "https://get.helm.sh/helm-${HELM_VER}-linux-amd64.tar.gz"
  tar -zxf helm.tar.gz &&
    chmod +x ./linux-amd64/helm &&
    mv ./linux-amd64/helm /usr/local/bin/ &&
    rm -rf helm.tar.* ./linux-amd64
  helm version
}

install_helm_plugin() {
  echo "Installing helm plugins"
  helm plugin install https://github.com/hypnoglow/helm-s3.git --version 0.14.0 2>&1 > /dev/null
  helm plugin install https://github.com/databus23/helm-diff 2>&1 > /dev/null
  helm plugin list
}

install_helmfile() {
  curl -L -s -o helmfile.tar.gz "https://github.com/helmfile/helmfile/releases/download/v${HELMFILE_VER}/helmfile_${HELMFILE_VER}_linux_amd64.tar.gz"
  tar -zxf helmfile.tar.gz -C . &&
    chmod +x helmfile &&
    sudo mv helmfile /usr/local/bin/ &&
    rm helmfile.tar.gz
}

install_kubectl
install_helm
install_helm_plugin
install_helmfile
