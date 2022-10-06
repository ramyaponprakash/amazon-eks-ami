#!/bin/bash

# https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html
#KUBECTL_VER="1.22.6/2022-03-09"

# https://github.com/helm/helm/releases
# https://helm.sh/docs/topics/version_skew/
#HELM_VER="v3.9.2"
#HELMFILE_VER="0.145.2"


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
  aws eks --region ap-southeast-1 update-kubeconfig --name ${cluster_name}
  eksctl utils associate-iam-oidc-provider --region=ap-southeast-1 --cluster=${cluster_name} --approve

}

install_kubectl() {
  echo "Installing kubectl - version: ${kubectl_version}"
  curl -o kubectl "https://s3.us-west-2.amazonaws.com/amazon-eks/${kubectl_version}/bin/linux/amd64/kubectl"
  chmod +x ./kubectl &&
  mv ./kubectl /usr/local/bin/kubectl
  kubectl version --short --client
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
  mv /.local /root
  echo "Installing helmfile - version: ${helmfile_version}"
  curl -L -o helmfile.tar.gz "https://github.com/helmfile/helmfile/releases/download/v${helmfile_version}/helmfile_${helmfile_version}_linux_amd64.tar.gz"
  mkdir helmfile &&
  tar -zxvf helmfile.tar.gz -C helmfile &&
  chmod +x ./helmfile/helmfile &&
  mv ./helmfile/helmfile /usr/local/bin/helmfile &&
  rm -rf ./helmfile helmfile.tar.gz
}

install_helpers() {
  apt-get update -y
  RANDOM_START=$(( ( RANDOM % 30 )  + 1 ))
  sleep $RANDOM_START
  apt-get install -y jq
  #snap install jq
  sleep 120
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
  aws configure set default.region ap-southeast-1
  export aws_secret_key=`aws secretsmanager get-secret-value --secret-id dev/aws_cli_keys --region ${region} | jq --raw-output '.SecretString' | jq -r .AWS_SECRET_KEY`
  export aws_access_key=`aws secretsmanager get-secret-value --secret-id dev/aws_cli_keys --region ${region} | jq --raw-output '.SecretString' | jq -r .AWS_ACCESS_KEY`
  cat << EndOfConfig > /root/.aws/credentials
  [default]
        aws_secret_access_key = $aws_secret_key
        aws_access_key_id     = $aws_access_key
EndOfConfig
}

# Allow Bamboo SSH task to pass build variables
enabled_bamboo_envvars() {
  sed -zi '/AcceptEnv bamboo_*/!s/$/\nAcceptEnv bamboo_*/' /etc/ssh/sshd_config
  systemctl restart ssh
}

install_mongo() {
  wget -qO - https://www.mongodb.org/static/pgp/server-4.4.asc | sudo apt-key add -
  echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/4.4 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.4.list
  sudo apt-get update
  wget http://archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.0g-2ubuntu4_amd64.deb
  sudo dpkg -i ./libssl1.1_1.1.0g-2ubuntu4_amd64.deb
  rm -i libssl1.1_1.1.0g-2ubuntu4_amd64.deb
  sudo apt-get install -y mongodb-org
  sudo systemctl start mongod
  wget https://s3.amazonaws.com/rds-downloads/rds-combined-ca-bundle.pem
}

install_helpers
install_command_if_not_exist aws install_awscli
install_eksctl
install_kubectl
install_helm
enabled_bamboo_envvars
install_mongo