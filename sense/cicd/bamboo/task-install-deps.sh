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


# TODO: remove some step once agent AMI is ready for this
echo "Installing dependencies"
mkdir ./tmp

# TODO: remove install_awscliv2 step once agent AMI is ready for this
install_awscliv2() {
  curl -L -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  unzip -qq awscliv2.zip
  ./aws/install -i /tmp/aws-cli -b /tmp
  rm -rf aws awscliv2.zip
}
install_command_if_not_exist /tmp/aws install_awscliv2
/tmp/aws --version

install_kubectl() {
  curl -L -s -o kubectl "https://s3.us-west-2.amazonaws.com/amazon-eks/${KUBECTL_VER}/bin/linux/amd64/kubectl"
  chmod +x ./kubectl &&
    mv ./kubectl /tmp/kubectl
}
install_command_if_not_exist /tmp/kubectl install_kubectl
/tmp/kubectl version --short --client

install_helm() {
    curl -L -s -o helm.tar.gz "https://get.helm.sh/helm-${HELM_VER}-linux-amd64.tar.gz"
    tar -zxf helm.tar.gz &&
      chmod +x ./linux-amd64/helm &&
      mv ./linux-amd64/helm /tmp/helm &&
      rm -rf helm.tar.* ./linux-amd64
}
install_command_if_not_exist /tmp/helm install_helm
/tmp/helm version

install_helmfile() {
curl -L -s -o helmfile.tar.gz "https://github.com/helmfile/helmfile/releases/download/v${HELMFILE_VER}/helmfile_${HELMFILE_VER}_linux_amd64.tar.gz"
tar -zxf helmfile.tar.gz -C ./tmp &&
  chmod +x ./tmp/helmfile &&
  mv ./tmp/helmfile /tmp/helmfile &&
  rm helmfile.tar.gz
}
install_command_if_not_exist /tmp/helmfile install_helmfile
/tmp/helmfile --version

install_eksctl() {
  curl -s -L "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C .
  chmod +x ./eksctl &&
    mv ./eksctl /tmp/eksctl
}
install_command_if_not_exist /tmp/eksctl install_eksctl
/tmp/eksctl version

echo "Installing helm plugins"
/tmp/helm plugin remove s3 2>&1 > /dev/null
/tmp/helm plugin remove diff 2>&1 > /dev/null
helm plugin remove s3 2>&1 > /dev/null
helm plugin remove diff 2>&1 > /dev/null
/tmp/helm plugin install https://github.com/hypnoglow/helm-s3.git --version 0.14.0 2>&1 > /dev/null
/tmp/helm plugin install https://github.com/databus23/helm-diff 2>&1 > /dev/null
helm plugin install https://github.com/hypnoglow/helm-s3.git --version 0.14.0 2>&1 > /dev/null
helm plugin install https://github.com/databus23/helm-diff 2>&1 > /dev/null
/tmp/helm plugin list

echo "Installing dependencies - done!"
rm -rf ./tmp