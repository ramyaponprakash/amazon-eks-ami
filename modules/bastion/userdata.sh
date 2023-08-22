#!/bin/bash

#set -o pipefail
#set -o errexit

# https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html
#KUBECTL_VER="1.22.6/2022-03-09"

# https://github.com/helm/helm/releases
# https://helm.sh/docs/topics/version_skew/
#HELM_VER="v3.9.2"
#HELMFILE_VER="0.145.2"

setup_proxy() {
  # Skip update_env_vars task if http_proxy is "empty"
  if [ "${http_proxy}" == "" ]; then
    echo "Skipping update_env_vars task because http_proxy is empty"
    return
  fi

   # Write the environment variables to the temporary file
  cat <<EOF > /etc/environment
http_proxy="${http_proxy}"
https_proxy="${https_proxy}"
no_proxy="${no_proxy}"
EOF
  chmod 644 /etc/environment

  if [ "$PKG" == "apt" ]; then
    cat << EOF > /etc/apt/apt.conf.d/proxy.conf
Acquire::http::Proxy "${http_proxy}";
Acquire::https::Proxy "${https_proxy}";
EOF
  elif [ "$PKG" == "yum" ]; then
    cat << EOL >> /etc/yum.conf
proxy="${https_proxy}"
proxy_username=
proxy_password=
EOL
  fi
}

install_eksctl() {
  curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C .
  chmod +x ./eksctl
  mv ./eksctl /usr/local/bin/eksctl
  eksctl version
}

install_kubectl() {
  echo "Installing kubectl - version: ${kubectl_version}"
  curl -o kubectl "https://s3.us-west-2.amazonaws.com/amazon-eks/${kubectl_version}/bin/linux/amd64/kubectl"
  chmod +x ./kubectl &&
  mv ./kubectl /usr/local/bin/kubectl
  kubectl version --short --client
  aws eks update-kubeconfig --name "${cluster_name}" --region ap-southeast-1
}

install_helm() {
  echo "Installing helm - version: ${helm_version}"
  curl -o helm.tar.gz "https://get.helm.sh/helm-${helm_version}-linux-amd64.tar.gz"
  tar -zxvf helm.tar.gz &&
    chmod +x ./linux-amd64/helm &&
    mv ./linux-amd64/helm /usr/local/bin/helm &&
    rm -rf helm.tar.* ./linux-amd64
  helm version

  echo "Installing helm plugins"
  helm plugin install https://github.com/hypnoglow/helm-s3.git --version 0.14.0
  helm plugin install https://github.com/databus23/helm-diff

  echo "Installing helmfile - version: ${helmfile_version}"
  curl -L -o helmfile.tar.gz "https://github.com/helmfile/helmfile/releases/download/v${helmfile_version}/helmfile_${helmfile_version}_linux_amd64.tar.gz"
  mkdir helmfile &&
    tar -zxvf helmfile.tar.gz -C helmfile &&
    chmod +x ./helmfile/helmfile &&
    mv ./helmfile/helmfile /usr/local/bin/helmfile &&
    rm -rf ./helmfile helmfile.tar.gz
}

install_helpers() {
  echo 'export PATH=/usr/local/bin:$PATH' >> ~/.profile
  echo 'export PATH=/usr/local/bin:$PATH' >> ~/.bashrc

  if [ "$PKG" == "apt" ]; then
    apt-get update -y &&
      apt-get install -y jq unzip
  elif [ "$PKG" == "yum" ]; then
    yum update -y &&
     yum install -y jq unzip git
  fi

  wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64
  chmod a+x /usr/local/bin/yq
  yq --version
}

install_ssm_agent() {
  if [ "$PKG" == "apt" ]; then
    snap install amazon-ssm-agent --classic
    snap start amazon-ssm-agent
  elif [ "$PKG" == "yum" ]; then
    # NOTE: we remove ssm-agent of CTS image here and let amazon-eks-ami install it again
    #       yum exit 1 when package is already installed
    yum remove -y amazon-ssm-agent
    yum install -y amazon-ssm-agent
    systemctl enable amazon-ssm-agent && systemctl start amazon-ssm-agent
  fi
}

install_awscli() {
  echo "Uninstall preinstalled awscli v1"
  if [ "$PKG" == "apt" ]; then
    apt-get remove -y awscli
  elif [ "$PKG" == "yum" ]; then
    yum remove -y awscli
  fi

  curl -L "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  unzip -q awscliv2.zip
  ./aws/install --bin-dir /bin/ --update
  rm -rf aws awscliv2.zip
  aws --version
  aws configure set default.region ap-southeast-1
}

cleanup() {
  if [ "$PKG" == "apt" ]; then
    apt-get autoremove -y
  elif [ "$PKG" == "yum" ]; then
    yum autoremove -y &&
      yum clean all &&
      rm -rf /var/cache/yum
  fi

  systemctl daemon-reload
}


##### MAIN #####
if [ -x "$(command -v apt-get)" ]; then
  PKG="apt"
elif [ -x "$(command -v yum)" ]; then
  PKG="yum"
else
  echo "Unsupported Linux distribution"
  exit 1
fi

setup_proxy
set -a
source /etc/environment

install_helpers
install_awscli
install_eksctl
install_kubectl
install_helm
install_ssm_agent
cleanup
