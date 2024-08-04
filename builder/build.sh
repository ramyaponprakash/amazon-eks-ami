#!/bin/bash

set -o pipefail
set -o errexit

usage () {
  echo '============================================'
  echo 'CIS Amazon Linux 2 EKS optimised AMI builder'
  echo '============================================'
  echo 'Please run this within the host that able to access the ES via security group settings'
  echo '-a : aws account id'
  echo '-c : cluster name'
  echo '-k : k8 version'
  echo '-v : vpc id'
  echo '-s : subnet id'
  echo '-i : CIDR for temporal ECS instance security group ssh access'
  echo '-p : Allowing to run packer in public host (Dev)'
  echo '-g : Pre-defined security group id for packer'
  echo '--enable-own-cis : Enable own CIS hardening scripts'
  echo '--packer : packer binary'
  echo '--jq : jq binary'
  echo '--awscli : awscli binary'
  echo '--ami-owner : source AMI owner account'
  echo '--ami-name : source AMI name to filter the latest'
  echo '--repo-tag : the tag of the official repo'
  echo '--working-dir : working directory'
  echo '--ssh-user : ssh user by packer to the temp instance'
}

parse_inputs() {
  PACKER_BINARY="packer"
  JQ_BINARY="jq"
  AWSCLI_BINARY="aws"

  while [[ $# -gt 0 ]]; do
    case $1 in
      -a) ACCOUNT_ID="$2"; shift 2;;
      -c) CLUSTER_NAME="$2"; shift 2;;
      -k) K8_VERSION="$2"; shift 2;;
      -v) VPC_ID="$2"; shift 2;;
      -s) SUBNET_ID="$2"; shift 2;;
      -i) EXEC_CIDR="$2"; shift 2;;
      -p) PUBLIC_ACCESS="$2"; shift 2;;
      -g) SECURITY_GROUP_ID="$2"; shift 2;;
      --enable-own-cis) ENABLE_OWN_CIS_SCRIPTS="true"; shift 2;;
      --packer) PACKER_BINARY="$2"; shift 2;;
      --jq) JQ_BINARY="$2"; shift 2;;
      --awscli) AWSCLI_BINARY="$2"; shift 2;;
      --ami-owner) AMI_OWNER_ACCOUNT_ID="$2"; shift 2;;
      --ami-name) AMI_FILTER="$2"; shift 2;;
      --repo-tag) AMI_REPO_TAG="$2"; shift 2;;
      --working-dir) WORKING_DIR="$2"; shift 2;;
      --ssh-user) SSH_USER="$2"; shift 2;;
      -h|--help) usage; shift;;
      -*|--*) echo "Unknown option $1"; usage; exit 1;;
      *) echo "Unknown value $1"; usage; exit 1;;
    esac
  done
}

setup_aws_vars() {
  AWS_REGION="ap-southeast-1"
  if [ -z "$ACCOUNT_ID" ]; then
      ACCOUNT_ID=$(aws sts get-caller-identity --region $AWS_REGION --output text --query Account)
  fi
  if [ -z "$VPC_ID" ] || [ -z "$SUBNET_ID" ]; then
    echo "AMI builder VPC_ID or SUBNET_ID not provided, will use EKS cluster's setup"
    VPC_ID=$(aws eks describe-cluster --region $AWS_REGION --name "$CLUSTER_NAME" --output text --query 'cluster.resourcesVpcConfig.vpcId')
    SUBNET_ID=$(aws eks describe-cluster --region $AWS_REGION --name "$CLUSTER_NAME" --output text --query 'cluster.resourcesVpcConfig.subnetIds[0]')
  fi
  echo "ACCOUNT_ID=$ACCOUNT_ID"
  echo "AWS_REGION=$AWS_REGION"
  echo "VPC_ID=$VPC_ID"
  echo "SUBNET_ID=$SUBNET_ID"
  echo "SECURITY_GROUP_ID=$SECURITY_GROUP_ID"
}

get_latest_ami_vars() {
  AMI_ID=$(aws ec2 describe-images --region $AWS_REGION --owners $AMI_OWNER_ACCOUNT_ID --filters "Name=name,Values=$AMI_FILTER*" --query 'sort_by(Images, &CreationDate)[-1].ImageId' --output text)
  AMI_NAME=$(aws ec2 describe-images --region $AWS_REGION --owners $AMI_OWNER_ACCOUNT_ID --filters "Name=name,Values=$AMI_FILTER*" --query 'sort_by(Images, &CreationDate)[-1].Name' --output text)
  echo "AMI_OWNER_ACCOUNT_ID=$AMI_OWNER_ACCOUNT_ID"
  echo "AMI_FILTER=$AMI_FILTER"
  echo "AMI_ID=$AMI_ID"
  echo "AMI_NAME=$AMI_NAME"
  echo "AMI_OWNER_ACCOUNT_ID=$AMI_OWNER_ACCOUNT_ID"
}

install_packer() {
  if [ "$PLATFORM" == "Darwin" ]; then
    curl -O https://releases.hashicorp.com/packer/$1/packer_$1_darwin_amd64.zip
    unzip packer_$1_darwin_amd64.zip && rm packer_$1_darwin_amd64.zip
  elif [ "$PLATFORM" == "Linux" ]; then
    wget https://releases.hashicorp.com/packer/$1/packer_$1_linux_amd64.zip
    unzip packer_$1_linux_amd64.zip && rm packer_$1_linux_amd64.zip
  else
    echo "$PLATFORM does not support" && exit 1
  fi
}

install_jq() {
  if [ "$PLATFORM" == "Darwin" ]; then
    curl -O -L https://github.com/jqlang/jq/releases/download/$1/jq-osx-amd64
    mv jq-osx-amd64 jq && chmod +x jq
  elif [ "$PLATFORM" == "Linux" ]; then
    wget https://github.com/stedolan/jq/releases/download/$1/jq-linux64
    mv jq-linux64 jq && chmod +x jq
  else
    echo "$PLATFORM does not support" && exit 1
  fi
}

install_deps() {
  echo "JQ_BINARY=$JQ_BINARY"
  echo "PACKER_BINARY=$PACKER_BINARY"

  PLATFORM=$(uname)
  PACKER_VERSION="1.9.1"
  if ! command -v $PACKER_BINARY &> /dev/null; then
    echo "packer not installed, installing ..."
    install_packer $PACKER_VERSION
  fi

  REQUIRED_PACKER_VERSION="v1.8.0"
  INSTALLED_PACKER_VERSION=$($PACKER_BINARY version | awk '{print $2}')
  if [[ $(printf '%s\n' "$REQUIRED_PACKER_VERSION" "$INSTALLED_PACKER_VERSION" | sort -rV | head -n1) != "$REQUIRED_PACKER_VERSION" ]]; then
      echo "Packer version $INSTALLED_PACKER_VERSION is above $REQUIRED_PACKER_VERSION"
  else
      echo "Packer version $INSTALLED_PACKER_VERSION is not above $REQUIRED_PACKER_VERSION, installing packer v$PACKER_VERSION"
      install_packer $PACKER_VERSION
  fi

  if ! command -v $JQ_BINARY &> /dev/null; then
    echo "jq not installed, installing ..."
    install_jq "jq-1.6"
  fi
}

ensure_repo() {
  echo "cleaning repo $1"
  rm -rf $1
  echo "git submodule update --remote"
  git submodule update --remote
  if [ -d "$1" ]; then
      echo "git submodule fetched"
  else
      echo "git submodule failed, fetching directly"
      git clone https://github.com/awslabs/amazon-eks-ami.git
  fi

  cd "$1"
  if [ -n "$AMI_REPO_TAG"  ]; then
    echo "git tag specified as $AMI_REPO_TAG"
    git config --global advice.detachedHead false
    git fetch --all -v &&
      git checkout "$AMI_REPO_TAG" &&
      echo "Branch: $(git branch --show-current)" &&
      echo "Tag: $(git describe --tags --exact-match 2>/dev/null)"
  fi
  cd "$WORKING_DIR"
}

modify_repo_scripts_cis_compatibility() {
  sed -i -e "s#/tmp#$1#g" $2/eks-worker-al2.json
  sed -i -e "s#/tmp#$1#g" $2/scripts/cleanup.sh
  sed -i -e "s#/tmp#$1#g" $2/scripts/generate-version-info.sh
  sed -i -e "s#/tmp#$1#g" $2/scripts/install-worker.sh
  sed -i -e "s#/tmp#$1#g" $2/log-collector-script/linux/eks-log-collector.sh
  sed -i -e "s#/tmp#$1#g" $2/files/bootstrap.sh
  sed -i -e "s#/tmp#$1#g" $2/files/bin/imds

  sed -i -e 's#chmod +x#chmod 755#g' $2/eks-worker-al2.json
  sed -i -e 's#sudo chmod +x $binary#sudo chmod 755 $binary#g' $2/scripts/install-worker.sh
  sed -i -e 's#aws --version#sudo /bin/aws --version#g' $2/scripts/generate-version-info.sh

  # https://github.com/hashicorp/packer/issues/10011
  echo "Adding CIS compatibility to packer conf file"
  $JQ_BINARY '(.provisioners[] | select(.type == "shell" and (.execute_command | not))) |= . + {"execute_command": "{{ .Vars }} bash '\''{{ .Path }}'\''"}' $2/eks-worker-al2.json > $2/temp.json && mv $2/temp.json $2/eks-worker-al2.json
}

add_pre_provisioning_scripts() {
  echo "Adding pre scripts to packer conf file"
  $JQ_BINARY ".provisioners = [{
      \"type\": \"shell\",
      \"remote_folder\": \"{{ user \`remote_folder\` }}\",
      \"expect_disconnect\": true,
      \"pause_after\": \"90s\",
      \"scripts\": [
        \"{{template_dir}}/scripts/pre_update.sh\"
      ],
      \"execute_command\": \"{{ .Vars }} sudo -S -E bash -eux '{{ .Path }}'\"
  }] + .provisioners" "$1/eks-worker-al2.json" > "$1/temp.json" && mv "$1/temp.json" "$1/eks-worker-al2.json"
}

add_pre_cis_scripts() {
  echo "Adding pre scripts to packer conf file"
  $JQ_BINARY ".provisioners = [{
      \"type\": \"shell\",
      \"remote_folder\": \"{{ user \`remote_folder\` }}\",
      \"expect_disconnect\": true,
      \"pause_after\": \"90s\",
      \"scripts\": [
        \"{{template_dir}}/scripts/pre_cis_iptables.sh\",
        \"{{template_dir}}/scripts/pre_cis_amaz2.sh\"
      ],
      \"execute_command\": \"{{ .Vars }} sudo -S -E bash -eux '{{ .Path }}'\"
  }] + .provisioners" "$1/eks-worker-al2.json" > "$1/temp.json" && mv "$1/temp.json" "$1/eks-worker-al2.json"
}

add_post_provisioning_scripts() {
  echo "Adding post scripts to packer conf file"
  $JQ_BINARY ".provisioners += [{
      \"type\": \"shell\",
      \"remote_folder\": \"{{ user \`remote_folder\` }}\",
      \"expect_disconnect\": true,
      \"pause_before\": \"60s\",
      \"pause_after\": \"30s\",
      \"scripts\": [
        \"{{template_dir}}/scripts/post_install.sh\",
        \"{{template_dir}}/scripts/post_harden.sh\"
      ],
      \"execute_command\": \"{{ .Vars }} sudo -S -E bash -eux '{{ .Path }}'\"
  }]" "$1/eks-worker-al2.json" > "$1/temp.json" && mv "$1/temp.json" "$1/eks-worker-al2.json"
}

main() {
  parse_inputs "$@"

  REMOTE_FOLDER="/home/ec2-user"
  REPO_FOLDER="$WORKING_DIR/amazon-eks-ami"

  if [ -n "$WORKING_DIR"  ]; then
    echo "working dir - '$WORKING_DIR'"
    cd "$WORKING_DIR"
  fi
  echo "PWD - $(pwd)"

  setup_aws_vars
  get_latest_ami_vars
  install_deps
  ensure_repo $REPO_FOLDER

  echo "Processing scripts and configs ..."
  cp -r "$WORKING_DIR/scripts/." "$REPO_FOLDER/scripts/
  echo "Processing scripts for 1.29 ..."
  cp -f "$WORKING_DIR/amazon-eks-ami/Makefile" "$REPO_FOLDER/Makefile"
  cat $REPO_FOLDER/Makefile
  modify_repo_scripts_cis_compatibility $REMOTE_FOLDER $REPO_FOLDER
  # optional run for non-CTS Images
  if [ "$ENABLE_OWN_CIS_SCRIPTS" == "true" ]; then
      echo "Own CIS script option enabled, adding scripts..."
      add_pre_cis_scripts $REPO_FOLDER
  fi
  add_pre_provisioning_scripts $REPO_FOLDER
  add_post_provisioning_scripts $REPO_FOLDER
  echo "packer config so far..."
  cat $REPO_FOLDER/eks-worker-al2.json

  AMI_NAME_PREFIX="adex-sol-eks-node-$K8_VERSION-v$(date +'%Y%m%d')-$(uuidgen)"
  if [ "$SSH_USER" == "" ]; then
    SSH_USER=ec2-user
  fi

  echo "baking AMI .... K8_VERSION=$K8_VERSION"
  make -C $REPO_FOLDER "$K8_VERSION" \
    PACKER_BINARY="../packer" \
    aws_region="$AWS_REGION" \
    source_ami_id="$AMI_ID" \
    source_ami_owners="$AMI_OWNER_ACCOUNT_ID" \
    source_ami_filter_name="$AMI_NAME" \
    ami_name="$AMI_NAME_PREFIX" \
    subnet_id="$SUBNET_ID" \
    volume_type="gp3" \
    launch_block_device_mappings_volume_size="20" \
    temporary_security_group_source_cidrs="$EXEC_CIDR" \
    associate_public_ip_address="$PUBLIC_ACCESS" \
    security_group_id="$SECURITY_GROUP_ID" \
    remote_folder="$REMOTE_FOLDER" \
    ssh_username="$SSH_USER"
  echo "baking AMI .... DONE!"

  echo "version-info.json"
  $JQ_BINARY . "$REPO_FOLDER/$AMI_NAME_PREFIX-version-info.json"
}

main "$@"
