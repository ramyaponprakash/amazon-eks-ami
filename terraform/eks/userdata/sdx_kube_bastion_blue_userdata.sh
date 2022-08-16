#!/bin/bash

# https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html
KUBECTL_VER="1.22.6/2022-03-09"

# https://github.com/helm/helm/releases
# https://helm.sh/docs/topics/version_skew/
HELM_VER="v3.9.2"
HELMFILE_VER="0.145.2"

install_command_if_not_exist() {
  if ! command -v $1 &> /dev/null
  then
    $2
  else
    echo "The cli '$1' already exist, skip installing"
  fi
}

install_eksctl() {
  curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C .
  chmod +x ./eksctl
  mv ./eksctl /usr/local/bin/eksctl
  eksctl version
}

install_kubectl() {
  echo "Installing kubectl - version: ${KUBECTL_VER}"
  curl -o kubectl "https://s3.us-west-2.amazonaws.com/amazon-eks/${KUBECTL_VER}/bin/linux/amd64/kubectl"
  chmod +x ./kubectl &&
  mv ./kubectl /usr/local/bin/kubectl
  kubectl version --short --client
}

install_helm() {
  echo "Installing helm - version: ${HELM_VER}"
  curl -o helm.tar.gz "https://get.helm.sh/helm-${HELM_VER}-linux-amd64.tar.gz"
  tar -zxvf helm.tar.gz &&
  chmod +x ./linux-amd64/helm &&
  mv ./linux-amd64/helm /usr/local/bin/helm &&
  rm -rf helm.tar.* ./linux-amd64
  helm version

  echo "Installing helm plugins"
  helm plugin install https://github.com/hypnoglow/helm-s3.git
  echo "Installing helmfile - version: ${HELMFILE_VER}"
  curl -L -o helmfile.tar.gz "https://github.com/helmfile/helmfile/releases/download/v${HELMFILE_VER}/helmfile_${HELMFILE_VER}_linux_amd64.tar.gz"
  mkdir helmfile &&
  tar -zxvf helmfile.tar.gz -C helmfile &&
  chmod +x ./helmfile/helmfile &&
  mv ./helmfile/helmfile /usr/local/bin/helmfile &&
  rm -rf ./helmfile helmfile.tar.gz
}

install_helpers() {
  apt-get install -y jq
  wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64
  chmod a+x /usr/local/bin/yq
  yq --version
}

install_awscli() {
  apt-get install -y unzip
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  unzip awscliv2.zip
  ./aws/install
  rm -rf aws awscliv2.zip
  aws --version
}

install_helpers
install_command_if_not_exist aws install_awscli
install_eksctl
install_kubectl
install_helm
